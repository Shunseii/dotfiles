"""PRs tab for the goto picker, fed by the session-prs Claude Code mod.

session-prs keeps each Claude session's pull requests in its mod store, a JSON
file under ~/.claude/plugins/store keyed `session:<session id>`. This view reads
that file, mirrors the mod's own pane (this session by default, `a` widens to
every agent open in herdr, `o` opens, `y` yanks, `r` re-reads state from gh), and
adds one thing the mod cannot: Enter jumps to the herdr pane running the PR's
session. Sessions with no live herdr pane are left out.

The store belongs to the mod, so refreshed states stay in memory here, exactly
like the mod's own wider view treats other sessions' rows.
"""

import curses
import json
import shutil
import subprocess
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path

import herdr_client

STORE_DIR = Path.home() / ".claude/plugins/store"
SESSIONS_DIR = Path.home() / ".claude/sessions"
STORE_PREFIX = "session:"
SETTLED = ("merged", "closed")
GH_TIMEOUT_S = 15
ORDER_FILE = "pr_order.json"
ORDER_LIMIT = 2000

STATE_ORDER = ["open", "draft", "merged", "closed", "unknown"]
# state -> (tag, color pair id, extra attr)
STATE_STYLE = {
    "open": ("open", 3, curses.A_BOLD),
    "draft": ("draft", 0, curses.A_DIM),
    "merged": ("merged", 5, 0),
    "closed": ("closed", 2, curses.A_DIM),
    "unknown": ("?", 0, curses.A_DIM),
}


@dataclass
class Pr:
    id: str
    repo: str
    number: int
    title: str
    url: str
    state: str


@dataclass
class SessionPrs:
    session_id: str
    name: str
    saved_at: float
    prs: list
    pane_id: str


@dataclass
class Item:
    pr: Pr | None = None
    session: SessionPrs | None = None
    header: str | None = None
    is_current: bool = False


def live_session_names():
    names = {}
    for path in SESSIONS_DIR.glob("*.json"):
        try:
            record = json.loads(path.read_text())
        except (OSError, ValueError):
            continue
        if record.get("sessionId") and record.get("name"):
            names[record["sessionId"]] = record["name"]
    return names


def load_sessions(snapshot):
    """Every session-prs store file merged, keeping only sessions live in a herdr pane."""
    panes_by_session = {}
    for pane in snapshot.get("panes", []):
        session_id = (pane.get("agent_session") or {}).get("value")
        if session_id:
            panes_by_session[session_id] = pane["pane_id"]
    names = live_session_names()

    saved = {}
    for path in STORE_DIR.glob("session-prs_*.json"):
        try:
            store = json.loads(path.read_text())
        except (OSError, ValueError):
            continue
        for key, value in store.items():
            if not key.startswith(STORE_PREFIX) or not isinstance(value, dict):
                continue
            current = saved.get(key)
            if current is None or value.get("savedAt", 0) > current.get("savedAt", 0):
                saved[key] = value

    sessions = []
    for key, value in saved.items():
        prs = [
            Pr(
                id=pr.get("id") or f"{pr['repo']}#{pr['number']}",
                repo=pr["repo"],
                number=pr["number"],
                title=pr.get("title") or "",
                url=pr.get("url") or f"https://github.com/{pr['repo']}/pull/{pr['number']}",
                state=pr.get("state") or "unknown",
            )
            for pr in value.get("prs", [])
            if pr.get("repo") and pr.get("number")
        ]
        session_id = key[len(STORE_PREFIX):]
        if not prs or session_id not in panes_by_session:
            continue
        sessions.append(
            SessionPrs(
                session_id=session_id,
                name=names.get(session_id) or value.get("name") or session_id[:8],
                saved_at=value.get("savedAt", 0),
                prs=prs,
                pane_id=panes_by_session[session_id],
            )
        )
    return stable_order(sessions)


def order_path():
    return herdr_client.history_path().with_name(ORDER_FILE)


def stable_order(sessions):
    """Order by when each PR first appeared, newest first, so rows only move for new PRs.

    The mod bumps savedAt on every state check, so sorting by it reshuffles
    sessions constantly. First-seen times are persisted; on the very first run
    they are seeded from savedAt so the initial order still looks sensible.
    """
    try:
        first_seen = json.loads(order_path().read_text())
        seeding = False
    except (OSError, ValueError):
        first_seen = {}
        seeding = True
    now = time.time() * 1000
    changed = False
    for session in sessions:
        for index, pr in enumerate(session.prs):
            key = f"{session.session_id}|{pr.id}"
            if key not in first_seen:
                first_seen[key] = (session.saved_at if seeding else now) + index
                changed = True
    if changed:
        if len(first_seen) > ORDER_LIMIT:
            first_seen = dict(sorted(first_seen.items(), key=lambda kv: kv[1])[-ORDER_LIMIT:])
        path = order_path()
        tmp = path.with_suffix(".tmp")
        tmp.write_text(json.dumps(first_seen))
        tmp.replace(path)

    def seen(session, pr):
        return first_seen[f"{session.session_id}|{pr.id}"]

    for session in sessions:
        session.prs.sort(key=lambda pr: seen(session, pr), reverse=True)
    return sorted(sessions, key=lambda one: max(seen(one, pr) for pr in one.prs), reverse=True)


def state_from_gh(answer):
    if answer.get("state") == "MERGED":
        return "merged"
    if answer.get("state") == "CLOSED":
        return "closed"
    if answer.get("isDraft"):
        return "draft"
    if answer.get("state") == "OPEN":
        return "open"
    return "unknown"


def read_from_gh(pr):
    try:
        result = subprocess.run(
            ["gh", "pr", "view", str(pr.number), "--repo", pr.repo, "--json", "title,url,state,isDraft"],
            capture_output=True,
            text=True,
            timeout=GH_TIMEOUT_S,
        )
        if result.returncode != 0:
            return None
        answer = json.loads(result.stdout)
        return {"state": state_from_gh(answer), "title": answer.get("title"), "url": answer.get("url")}
    except (OSError, ValueError, subprocess.TimeoutExpired):
        return None


class PrView:
    def __init__(self, ui, scope):
        self.ui = ui
        self.scope = scope if scope in ("mine", "all") else "mine"
        self.sessions = []
        self.current_session_id = None
        self.fresh = {}
        self.fresh_lock = threading.Lock()
        self.refreshing = False
        self.items = []
        self.cursor = 0
        self.scroll = 0
        self.refreshed_once = False
        self.hide_merged = bool(herdr_client.load_prefs().get("hide_merged", False))
        self.hidden_merged = 0

    # ---- data ------------------------------------------------------------

    def reload(self, snapshot):
        focused = snapshot.get("focused_pane_id")
        self.current_session_id = None
        for pane in snapshot.get("panes", []):
            if pane["pane_id"] == focused:
                self.current_session_id = (pane.get("agent_session") or {}).get("value")
        self.sessions = load_sessions(snapshot)
        self.rebuild()
        if not self.refreshed_once:
            self.refreshed_once = True
            self.refresh()

    def with_fresh(self, pr):
        with self.fresh_lock:
            update = self.fresh.get(pr.id)
        if not update:
            return pr
        return Pr(
            id=pr.id,
            repo=pr.repo,
            number=pr.number,
            title=update.get("title") or pr.title,
            url=update.get("url") or pr.url,
            state=update.get("state") or pr.state,
        )

    def refresh(self, everything=False):
        if self.refreshing:
            return
        due = {}
        for session in self.sessions:
            for pr in session.prs:
                if everything or self.with_fresh(pr).state not in SETTLED:
                    due[pr.id] = pr
        if not due or not shutil.which("gh"):
            return
        self.refreshing = True

        def work():
            try:
                with ThreadPoolExecutor(max_workers=8) as pool:
                    for pr, answer in zip(due.values(), pool.map(read_from_gh, due.values())):
                        if answer:
                            with self.fresh_lock:
                                self.fresh[pr.id] = answer
            finally:
                self.refreshing = False

        threading.Thread(target=work, daemon=True).start()

    def visible(self, pr, session):
        if self.hide_merged and pr.state == "merged":
            self.hidden_merged += 1
            return False
        return self.matches(pr, session)

    def matches(self, pr, session):
        words = self.ui.query.lower().split()
        haystack = f"{pr.title} {pr.repo} #{pr.number} {pr.state} {session.name}".lower()
        return all(word in haystack for word in words)

    def rebuild(self):
        selected = self.selected()
        keep = (selected.pr.id, selected.session.session_id) if selected else None
        items = []
        self.hidden_merged = 0
        if self.scope == "mine":
            for session in self.sessions:
                if session.session_id == self.current_session_id:
                    items.extend(
                        Item(pr=self.with_fresh(pr), session=session, is_current=True)
                        for pr in session.prs
                        if self.visible(self.with_fresh(pr), session)
                    )
        else:
            ordered = sorted(self.sessions, key=lambda one: one.session_id != self.current_session_id)
            for session in ordered:
                rows = [
                    Item(pr=self.with_fresh(pr), session=session, is_current=session.session_id == self.current_session_id)
                    for pr in session.prs
                    if self.visible(self.with_fresh(pr), session)
                ]
                if rows:
                    is_current = session.session_id == self.current_session_id
                    items.append(Item(header="this session" if is_current else session.name, session=session, is_current=is_current))
                    items.extend(rows)
        self.items = items
        if keep:
            for index, item in enumerate(items):
                if item.pr and (item.pr.id, item.session.session_id) == keep:
                    self.cursor = index
                    return
        selectable = [i for i, item in enumerate(items) if item.pr]
        self.cursor = selectable[0] if selectable else 0

    def selected(self):
        if 0 <= self.cursor < len(self.items) and self.items[self.cursor].pr:
            return self.items[self.cursor]
        return None

    def move(self, delta):
        selectable = [i for i, item in enumerate(self.items) if item.pr]
        if not selectable:
            return
        position = selectable.index(self.cursor) + delta if self.cursor in selectable else 0
        self.cursor = selectable[max(0, min(len(selectable) - 1, position))]

    # ---- actions -----------------------------------------------------------

    def open_in_browser(self):
        item = self.selected()
        if not item:
            return
        subprocess.Popen(
            ["xdg-open", item.pr.url],
            start_new_session=True,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        self.ui.message = f"opened #{item.pr.number} in the browser"

    def yank(self):
        item = self.selected()
        if not item:
            return
        copier = ["wl-copy"] if shutil.which("wl-copy") else ["xclip", "-selection", "clipboard"]
        try:
            subprocess.run(copier, input=item.pr.url, text=True, timeout=3, check=True)
            self.ui.message = f"copied {item.pr.url}"
        except (OSError, subprocess.SubprocessError):
            self.ui.message = "couldn't copy: install wl-copy or xclip"

    def go_to_session(self):
        item = self.selected()
        if not item:
            return False
        herdr_client.request("pane.focus", {"pane_id": item.session.pane_id})
        return True

    def toggle_scope(self):
        self.scope = "all" if self.scope == "mine" else "mine"
        self.rebuild()

    def handle_key(self, key):
        """Returns "quit"/"jumped" to close the picker, else None."""
        if key in ("j", curses.KEY_DOWN, "\x0e"):
            self.move(1)
        elif key in ("k", curses.KEY_UP, "\x10"):
            self.move(-1)
        elif key in ("G", curses.KEY_END):
            self.move(len(self.items))
        elif key == curses.KEY_HOME:
            self.move(-len(self.items))
        elif key == "o":
            self.open_in_browser()
        elif key == "y":
            self.yank()
        elif key == "a":
            self.toggle_scope()
        elif key == "m":
            self.hide_merged = not self.hide_merged
            herdr_client.save_prefs({**herdr_client.load_prefs(), "hide_merged": self.hide_merged})
            self.rebuild()
        elif key == "r":
            self.refresh(everything=True)
            self.ui.message = "re-reading every PR's state from gh…"
        elif key in ("\n", "\r", curses.KEY_ENTER):
            if self.go_to_session():
                return "jumped"
        return None

    # ---- drawing -----------------------------------------------------------

    def footer_hints(self):
        return [
            ("j k", "move"),
            ("o", "open"),
            ("y", "yank"),
            ("a", "mine" if self.scope == "all" else "all"),
            ("m", "show merged" if self.hide_merged else "hide merged"),
            ("r", "reload"),
            ("enter", "go to session"),
            ("/", "search"),
            ("p", "panes"),
            ("q", "quit"),
        ]

    def draw_header_extras(self, y, x, width):
        x = self.ui.draw_segments(y, x, [("mine", "This session"), ("all", "Every agent")], self.scope)
        if self.refreshing:
            self.ui.put(y, x + 2, "⟳ gh", curses.A_DIM)
        counts = {}
        for item in self.items:
            if item.pr:
                counts[item.pr.state] = counts.get(item.pr.state, 0) + 1
        chunks = [(state, f"{counts[state]} {STATE_STYLE[state][0]}") for state in STATE_ORDER if counts.get(state)]
        if self.hidden_merged:
            chunks.append(("unknown", f"{self.hidden_merged} merged hidden"))
        cx = width - sum(len(text) + 2 for _, text in chunks) - 1
        if cx <= x + 8:
            return
        for state, text in chunks:
            _, pair, extra = STATE_STYLE[state]
            self.ui.put(y, cx, text, curses.color_pair(pair) | extra)
            cx += len(text) + 2

    def draw_list(self, top, height, width):
        if self.cursor < self.scroll:
            self.scroll = self.cursor
        if self.cursor >= self.scroll + height:
            self.scroll = self.cursor - height + 1
        if self.cursor - 1 >= 0 and self.items and self.items[self.cursor - 1].header and self.scroll == self.cursor:
            self.scroll = self.cursor - 1

        repo_width = max(8, min(18, int(width * 0.14)))
        session_width = max(10, min(24, int(width * 0.2)))
        title_x = 3 + 8 + 8
        title_width = max(10, width - title_x - repo_width - session_width - 6)
        self.ui.put(top - 1, 3, "STATE", curses.A_DIM | curses.A_BOLD)
        self.ui.put(top - 1, 11, "PR", curses.A_DIM | curses.A_BOLD)
        self.ui.put(top - 1, title_x, "TITLE", curses.A_DIM | curses.A_BOLD)
        self.ui.put(top - 1, title_x + title_width + 2, "REPO", curses.A_DIM | curses.A_BOLD)
        self.ui.put(top - 1, width - session_width - 1, "SESSION", curses.A_DIM | curses.A_BOLD)

        for line, index in enumerate(range(self.scroll, min(len(self.items), self.scroll + height))):
            item = self.items[index]
            y = top + line
            if item.header is not None:
                attr = curses.color_pair(6) | curses.A_BOLD
                self.ui.put(y, 1, f"▾ {item.header}", attr)
                continue
            self.draw_row(y, width, item, index == self.cursor, title_x, title_width, repo_width, session_width)

        if not self.items:
            if self.scope == "mine":
                hint = "no PRs for the Claude session in this pane — a shows every open agent's"
            else:
                hint = "no PRs from agents open in herdr"
            if self.ui.query:
                hint = "nothing matches — esc clears search"
            self.ui.put(top + 1, 4, hint, curses.A_DIM)

        hidden = len(self.items) - (self.scroll + height)
        return hidden

    def draw_row(self, y, width, item, selected, title_x, title_width, repo_width, session_width):
        offset = 10 if selected else 0

        def style(pair=0, extra=0):
            return curses.color_pair(pair + offset) | extra

        if selected:
            self.ui.put(y, 0, " " * width, style())
            self.ui.put(y, 0, "▌", style(6, curses.A_BOLD))
        tag, pair, extra = STATE_STYLE.get(item.pr.state, STATE_STYLE["unknown"])
        self.ui.put(y, 3, f"{tag:<7}", style(pair, extra))
        self.ui.put(y, 11, f"#{item.pr.number}", style(0, curses.A_BOLD if selected else curses.A_DIM))
        self.ui.put(y, title_x, fit(item.pr.title, title_width), style(0, curses.A_BOLD if selected else 0))
        repo = item.pr.repo.split("/")[-1]
        self.ui.put(y, title_x + title_width + 2, fit(repo, repo_width), style(6))
        self.ui.put(y, width - session_width - 1, fit(item.session.name, session_width), style(0, curses.A_DIM))

    def draw_detail(self, y, width):
        item = self.selected()
        if not item:
            return
        self.ui.put(y, 1, item.pr.url, curses.A_DIM)
        self.ui.put(y, max(len(item.pr.url) + 3, width - len(item.session.name) - 2),
                    item.session.name, curses.color_pair(6))


def fit(text, width):
    if len(text) <= width:
        return text.ljust(width)
    return text[: max(0, width - 1)] + "…"
