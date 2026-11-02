"""Goto picker popup: recent-first pane list with kind/status filters and rename."""

import curses
import os
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path

import herdr_client

os.environ.setdefault("ESCDELAY", "25")

HERDR = os.environ.get("HERDR_BIN_PATH", "herdr")
HOME = str(Path.home())
REFRESH_MS = 1000

KIND_FILTERS = ["all", "agents", "shells"]
STATUS_KEYS = {"b": "blocked", "w": "working", "i": "idle", "d": "done"}

# status -> (glyph, label, color pair id)
STATUS_STYLE = {
    "blocked": ("▲", "blocked", 2),
    "working": ("●", "working", 1),
    "done": ("✓", "done", 3),
    "idle": ("○", "idle", 4),
    "unknown": ("?", "unknown", 5),
    "shell": ("$", "shell", 0),
}
STATUS_ORDER = ["blocked", "working", "done", "idle", "unknown"]

PAIR_ACCENT = 6
PAIR_KEY = 7
PAIR_CHIP = 8
PAIR_MESSAGE = 5
SELECTED_OFFSET = 10


@dataclass
class Row:
    pane_id: str
    tab_id: str
    workspace_id: str
    workspace_label: str
    workspace_number: int
    tab_label: str
    agent: str | None
    status: str
    path: str
    title: str
    focused: bool
    last_used: float = 0.0
    haystack: str = field(default="", repr=False)


def short_path(path):
    if path.startswith(HOME):
        return "~" + path[len(HOME):]
    return path


def display_label(tab_label, pane):
    """Unnamed tabs get a bare number from herdr; show something recognizable instead."""
    if tab_label and not tab_label.isdigit():
        return tab_label
    title = pane.get("terminal_title_stripped") or ""
    if title and title not in ("zsh", "bash", "sh"):
        return title
    path = pane.get("foreground_cwd") or pane.get("cwd") or ""
    return os.path.basename(path.rstrip("/")) or tab_label or "?"


def build_rows(snap, history):
    workspaces = {w["workspace_id"]: w for w in snap.get("workspaces", [])}
    tabs = {t["tab_id"]: t for t in snap.get("tabs", [])}
    pane_times = history.get("panes", {})
    tab_times = history.get("tabs", {})
    focused_pane = snap.get("focused_pane_id")
    rows = []
    for pane in snap.get("panes", []):
        workspace = workspaces.get(pane.get("workspace_id"), {})
        tab = tabs.get(pane.get("tab_id"), {})
        agent = pane.get("agent")
        status = (pane.get("agent_status") or "unknown") if agent else "shell"
        if status not in STATUS_STYLE:
            status = "unknown"
        row = Row(
            pane_id=pane["pane_id"],
            tab_id=pane.get("tab_id", ""),
            workspace_id=pane.get("workspace_id", ""),
            workspace_label=workspace.get("label") or pane.get("workspace_id", ""),
            workspace_number=workspace.get("number", 0),
            tab_label=display_label(tab.get("label"), pane),
            agent=agent,
            status=status,
            path=short_path(pane.get("foreground_cwd") or pane.get("cwd") or ""),
            title=pane.get("terminal_title_stripped") or "",
            focused=pane["pane_id"] == focused_pane,
        )
        if row.focused:
            row.last_used = float("inf")
        else:
            row.last_used = pane_times.get(row.pane_id) or tab_times.get(row.tab_id) or 0.0
        row.haystack = " ".join(
            [row.tab_label, row.workspace_label, row.path, row.agent or "shell", row.status, row.title]
        ).lower()
        rows.append(row)
    return rows


@dataclass
class ListItem:
    row: Row | None = None
    header: str | None = None


class Picker:
    def __init__(self, screen):
        self.screen = screen
        prefs = herdr_client.load_prefs()
        self.grouped = bool(prefs.get("grouped", False))
        self.kind_filter = prefs.get("kind_filter", "all")
        if self.kind_filter not in KIND_FILTERS:
            self.kind_filter = "all"
        self.status_filter = None
        self.query = ""
        self.searching = False
        self.message = ""
        self.rows = []
        self.items = []
        self.cursor = 0
        self.scroll = 0
        self.first_load = True

    def save_prefs(self):
        herdr_client.save_prefs({"grouped": self.grouped, "kind_filter": self.kind_filter})

    def reload(self):
        selected = self.selected_row()
        selected_id = selected.pane_id if selected else None
        self.rows = build_rows(herdr_client.snapshot(), herdr_client.load_history())
        self.rebuild(keep_pane=selected_id)

    def visible_rows(self):
        words = self.query.lower().split()
        result = []
        for row in self.rows:
            if self.kind_filter == "agents" and not row.agent:
                continue
            if self.kind_filter == "shells" and row.agent:
                continue
            if self.status_filter and row.status != self.status_filter:
                continue
            if any(word not in row.haystack for word in words):
                continue
            result.append(row)
        return sorted(result, key=lambda r: r.last_used, reverse=True)

    def rebuild(self, keep_pane=None):
        rows = self.visible_rows()
        items = []
        if self.grouped:
            by_workspace = {}
            for row in rows:
                by_workspace.setdefault(row.workspace_id, []).append(row)
            ordered = sorted(by_workspace.values(), key=lambda group: group[0].workspace_number)
            for group in ordered:
                items.append(ListItem(header=group[0].workspace_label))
                items.extend(ListItem(row=row) for row in group)
        else:
            items = [ListItem(row=row) for row in rows]
        self.items = items

        if keep_pane:
            for index, item in enumerate(items):
                if item.row and item.row.pane_id == keep_pane:
                    self.cursor = index
                    return
        selectable = self.selectable_indexes()
        if not selectable:
            self.cursor = 0
            return
        # Alt-tab feel: on open, start on the previously used pane, not the current one.
        if self.first_load and not self.grouped and len(selectable) > 1 and items[selectable[0]].row.focused:
            self.cursor = selectable[1]
        else:
            self.cursor = selectable[0]
        self.first_load = False

    def selectable_indexes(self):
        return [i for i, item in enumerate(self.items) if item.row]

    def selected_row(self):
        if 0 <= self.cursor < len(self.items):
            return self.items[self.cursor].row
        return None

    def move(self, delta):
        selectable = self.selectable_indexes()
        if not selectable:
            return
        if self.cursor not in selectable:
            self.cursor = selectable[0]
            return
        position = selectable.index(self.cursor) + delta
        self.cursor = selectable[max(0, min(len(selectable) - 1, position))]

    def jump_group(self, direction):
        if not self.grouped:
            return
        headers = [i for i, item in enumerate(self.items) if item.header is not None]
        if direction > 0:
            targets = [h for h in headers if h > self.cursor]
        else:
            current = max([h for h in headers if h < self.cursor], default=-1)
            targets = [h for h in headers if h < current]
            targets = targets[-1:]
        if targets and targets[0] + 1 < len(self.items):
            self.cursor = targets[0] + 1

    # ---- drawing -------------------------------------------------------

    def put(self, y, x, text, attr=0):
        height, width = self.screen.getmaxyx()
        if y < 0 or y >= height or x >= width:
            return
        try:
            self.screen.addnstr(y, x, text, max(0, width - x - (1 if y == height - 1 else 0)), attr)
        except curses.error:
            pass

    def draw(self):
        self.screen.erase()
        height, width = self.screen.getmaxyx()

        self.draw_header(0, width)
        self.draw_search(1, width)

        footer_lines = self.footer_layout(width)
        footer_top = height - len(footer_lines)
        detail_y = footer_top - 1
        list_top = 3
        list_height = max(1, detail_y - 1 - list_top)

        layout = self.column_layout(width)
        self.draw_column_titles(2, layout)

        if self.cursor < self.scroll:
            self.scroll = self.cursor
        if self.cursor >= self.scroll + list_height:
            self.scroll = self.cursor - list_height + 1
        if self.cursor - 1 >= 0 and self.items and self.items[self.cursor - 1].header and self.scroll == self.cursor:
            self.scroll = self.cursor - 1

        for line, index in enumerate(range(self.scroll, min(len(self.items), self.scroll + list_height))):
            item = self.items[index]
            y = list_top + line
            if item.header is not None:
                count = sum(1 for it in self.items if it.row and it.row.workspace_label == item.header)
                self.put(y, 1, f"▾ {item.header}", curses.color_pair(PAIR_ACCENT) | curses.A_BOLD)
                self.put(y, 4 + len(item.header), f"{count}", curses.A_DIM)
                continue
            self.draw_row(y, width, item.row, index == self.cursor, layout)

        if not self.items:
            self.put(list_top + 1, 4, "nothing matches — esc clears search, a clears status filter", curses.A_DIM)

        self.draw_detail(detail_y, width)
        hidden_below = len(self.items) - (self.scroll + list_height)
        if hidden_below > 0:
            self.put(detail_y - 1, width - 14, f" ↓ {hidden_below} more ", curses.A_DIM)
        for offset, line in enumerate(footer_lines):
            x = 1
            for key, label in line:
                self.put(footer_top + offset, x, f" {key} ", curses.color_pair(PAIR_KEY) | curses.A_BOLD)
                x += len(key) + 2
                self.put(footer_top + offset, x + 1, label, curses.A_DIM)
                x += len(label) + 3
        self.screen.refresh()

    def draw_header(self, y, width):
        x = 1
        self.put(y, x, "Goto", curses.A_BOLD)
        x += 6
        x = self.draw_segments(y, x, [("all", "All"), ("agents", "Agents"), ("shells", "Shells")], self.kind_filter)
        x += 2
        x = self.draw_segments(y, x, [(False, "Recent"), (True, "Grouped")], self.grouped)
        if self.status_filter:
            glyph, label, pair = STATUS_STYLE[self.status_filter]
            chip = f" {glyph} {label} only "
            self.put(y, x + 2, chip, curses.color_pair(pair) | curses.A_BOLD | curses.A_REVERSE)
            x += len(chip) + 2

        counts = {}
        for row in self.rows:
            counts[row.status] = counts.get(row.status, 0) + 1
        parts = [(s, counts[s]) for s in STATUS_ORDER + ["shell"] if counts.get(s)]
        chunks = [f"{STATUS_STYLE[s][0]} {n}" for s, n in parts]
        cx = width - sum(len(c) + 2 for c in chunks) - 1
        if cx <= x + 2:
            return
        for (status, _), chunk in zip(parts, chunks):
            attr = curses.color_pair(STATUS_STYLE[status][2])
            if status == "shell":
                attr |= curses.A_DIM
            self.put(y, cx, chunk, attr)
            cx += len(chunk) + 2

    def draw_segments(self, y, x, options, active):
        for value, label in options:
            text = f" {label} "
            if value == active:
                self.put(y, x, text, curses.color_pair(PAIR_CHIP) | curses.A_BOLD)
            else:
                self.put(y, x, text, curses.A_DIM)
            x += len(text)
        return x

    def draw_search(self, y, width):
        if self.searching or self.query:
            caret = "█" if self.searching else ""
            self.put(y, 1, "⌕", curses.color_pair(PAIR_ACCENT) | curses.A_BOLD)
            self.put(y, 3, f"{self.query}{caret}", curses.A_BOLD)
            visible = sum(1 for item in self.items if item.row)
            self.put(y, width - 14, f"{visible:>4} match{'es' if visible != 1 else ''}", curses.A_DIM)
        else:
            self.put(y, 1, "⌕", curses.A_DIM)
            self.put(y, 3, "press / to search", curses.A_DIM)

    def column_layout(self, width):
        status_width, agent_width, used_width = 10, 8, 5
        workspace_width = 0 if self.grouped else max(10, min(18, int(width * 0.15)))
        fixed = 3 + status_width + 1 + agent_width + 2 + used_width + 2 + (workspace_width + 2 if workspace_width else 0)
        flexible = max(10, width - fixed - 2)
        label_width = max(12, int(flexible * 0.5))
        path_width = max(0, flexible - label_width - 2)
        return {
            "status": (3, status_width),
            "agent": (3 + status_width + 1, agent_width),
            "label": (3 + status_width + 1 + agent_width + 2, label_width),
            "workspace": (3 + status_width + 1 + agent_width + 2 + label_width + 2, workspace_width),
            "used": (width - path_width - used_width - 3, used_width),
            "path": (width - path_width - 1, path_width),
        }

    def draw_column_titles(self, y, layout):
        titles = {"status": "STATUS", "agent": "AGENT", "label": "NAME", "workspace": "WORKSPACE", "used": " USED", "path": "PATH"}
        for column, (x, column_width) in layout.items():
            if column_width:
                self.put(y, x, titles[column][:column_width], curses.A_DIM | curses.A_BOLD)

    def draw_row(self, y, width, row, selected, layout):
        glyph, status_label, pair = STATUS_STYLE[row.status]

        def style(color_pair=0, extra=0):
            if selected:
                return curses.color_pair(color_pair + SELECTED_OFFSET) | extra
            return curses.color_pair(color_pair) | extra

        if selected:
            self.put(y, 0, " " * width, style())
            self.put(y, 0, "▌", style(PAIR_ACCENT, curses.A_BOLD))

        status_extra = curses.A_DIM if row.status == "shell" else (curses.A_BOLD if row.status in ("blocked", "done") else 0)
        x, _ = layout["status"]
        self.put(y, x, f"{glyph} {status_label}", style(pair, status_extra))

        x, column_width = layout["agent"]
        self.put(y, x, fit(row.agent or "—", column_width), style(0, 0 if row.agent else curses.A_DIM))

        x, column_width = layout["label"]
        here = " ◂ here" if row.focused else ""
        label = fit(row.tab_label, max(1, column_width - len(here)))
        self.put(y, x, label, style(0, curses.A_BOLD if selected or row.agent else 0))
        if here:
            self.put(y, x + len(label), here, style(PAIR_ACCENT))

        x, column_width = layout["workspace"]
        if column_width:
            self.put(y, x, fit(row.workspace_label, column_width), style(PAIR_ACCENT))

        x, column_width = layout["used"]
        self.put(y, x, f"{relative_age(row.last_used):>{column_width}}", style(0, curses.A_DIM))

        x, column_width = layout["path"]
        if column_width > 4:
            self.put(y, x, fit_left(row.path, column_width), style(0, curses.A_DIM))

    def draw_detail(self, y, width):
        self.put(y - 1, 0, "─" * width, curses.A_DIM)
        if self.message:
            self.put(y, 1, self.message.strip(), curses.color_pair(PAIR_MESSAGE) | curses.A_BOLD)
            return
        row = self.selected_row()
        if not row:
            return
        self.put(y, 1, row.workspace_label, curses.color_pair(PAIR_ACCENT))
        x = 2 + len(row.workspace_label)
        self.put(y, x, f"› {row.tab_label}", curses.A_BOLD)
        x += len(row.tab_label) + 4
        self.put(y, x, row.path, curses.A_DIM)
        self.put(y, width - len(row.pane_id) - 2, row.pane_id, curses.A_DIM)

    def footer_layout(self, width):
        if self.searching:
            hints = [("enter", "open"), ("↑↓", "move"), ("tab", "agents/shells"), ("^u", "clear"), ("esc", "cancel")]
        else:
            hints = [
                ("o", "open"),
                ("j k", "move"),
                ("/", "search"),
                ("tab", "agents/shells"),
                ("g", "recent/grouped"),
                ("r", "rename"),
                ("R", "auto-rename"),
                ("b w i d", "blocked/working/idle/done"),
                ("a", "all"),
            ]
            if self.grouped:
                hints.append(("h l", "prev/next workspace"))
            hints.append(("esc", "close"))
        lines, line, used = [], [], 1
        for key, label in hints:
            size = len(key) + 2 + 1 + len(label) + 2
            if line and used + size > width - 1:
                lines.append(line)
                line, used = [], 1
            line.append((key, label))
            used += size
        if line:
            lines.append(line)
        return lines

    # ---- actions -------------------------------------------------------

    def open_selected(self):
        row = self.selected_row()
        if not row:
            return False
        herdr_client.request("pane.focus", {"pane_id": row.pane_id})
        herdr_client.touch(pane_id=row.pane_id, tab_id=row.tab_id)
        return True

    def prompt(self, label, initial):
        text = initial
        self.screen.timeout(-1)
        curses.curs_set(1)
        try:
            while True:
                height, width = self.screen.getmaxyx()
                self.put(height - 1, 0, " " * (width - 1))
                prompt_text = f" {label}: {text}"
                self.put(height - 1, 0, prompt_text, curses.color_pair(6) | curses.A_BOLD)
                self.screen.move(height - 1, min(width - 2, len(prompt_text)))
                self.screen.refresh()
                key = self.screen.get_wch()
                if key in ("\n", "\r", curses.KEY_ENTER):
                    return text.strip()
                if key == "\x1b":
                    return None
                if key in (curses.KEY_BACKSPACE, "\x7f", "\b"):
                    text = text[:-1]
                elif key == "\x15":
                    text = ""
                elif key == "\x17":
                    text = text.rstrip().rpartition(" ")[0]
                elif isinstance(key, str) and key.isprintable():
                    text += key
        finally:
            curses.curs_set(0)
            self.screen.timeout(REFRESH_MS)

    def rename_selected(self):
        row = self.selected_row()
        if not row:
            return
        name = self.prompt("rename", row.tab_label)
        if not name or name == row.tab_label:
            self.message = ""
            return
        if row.agent == "claude":
            launch_rename_worker(row.pane_id, name)
            self.message = f"/rename “{name}” sent — tab syncs once Claude applies it"
        else:
            subprocess.run([HERDR, "tab", "rename", row.tab_id, name], capture_output=True)
            self.message = f"renamed tab to “{name}”"
        self.reload()

    def auto_rename_selected(self):
        row = self.selected_row()
        if not row:
            return
        if row.agent != "claude":
            self.message = "auto-rename needs a Claude pane — use r to rename this one"
            return
        launch_rename_worker(row.pane_id)
        self.message = "/rename sent — Claude is picking a name; tab syncs when it's set"

    # ---- loop ----------------------------------------------------------

    def handle_search_key(self, key):
        if key == "\x1b":
            self.searching = False
            self.query = ""
        elif key in ("\n", "\r", curses.KEY_ENTER):
            return "open"
        elif key in (curses.KEY_BACKSPACE, "\x7f", "\b"):
            if self.query:
                self.query = self.query[:-1]
            else:
                self.searching = False
        elif key == "\x15":
            self.query = ""
        elif key in (curses.KEY_DOWN, "\x0e"):
            self.move(1)
            return None
        elif key in (curses.KEY_UP, "\x10"):
            self.move(-1)
            return None
        elif key == "\t":
            self.cycle_kind()
        elif isinstance(key, str) and key.isprintable():
            self.query += key
        self.rebuild()
        return None

    def cycle_kind(self):
        self.kind_filter = KIND_FILTERS[(KIND_FILTERS.index(self.kind_filter) + 1) % len(KIND_FILTERS)]
        self.save_prefs()

    def handle_key(self, key):
        self.message = ""
        if self.searching:
            return self.handle_search_key(key)
        if key in ("\x1b", "q"):
            return "quit"
        if key in ("\n", "\r", curses.KEY_ENTER, "o"):
            return "open"
        if key in ("j", curses.KEY_DOWN, "\x0e"):
            self.move(1)
        elif key in ("k", curses.KEY_UP, "\x10"):
            self.move(-1)
        elif key in ("G", curses.KEY_END):
            self.move(len(self.items))
        elif key in (curses.KEY_HOME,):
            self.move(-len(self.items))
        elif key in ("l", curses.KEY_RIGHT):
            self.jump_group(1)
        elif key in ("h", curses.KEY_LEFT):
            self.jump_group(-1)
        elif key == "/":
            self.searching = True
        elif key == "\t":
            self.cycle_kind()
            self.rebuild()
        elif key == curses.KEY_BTAB:
            self.kind_filter = KIND_FILTERS[(KIND_FILTERS.index(self.kind_filter) - 1) % len(KIND_FILTERS)]
            self.save_prefs()
            self.rebuild()
        elif key == "g":
            self.grouped = not self.grouped
            self.save_prefs()
            row = self.selected_row()
            self.rebuild(keep_pane=row.pane_id if row else None)
        elif key in STATUS_KEYS:
            self.status_filter = STATUS_KEYS[key]
            self.rebuild()
        elif key == "a":
            self.status_filter = None
            self.rebuild()
        elif key == "r":
            self.rename_selected()
        elif key == "R":
            self.auto_rename_selected()
        return None

    def run(self):
        curses.curs_set(0)
        self.screen.timeout(REFRESH_MS)
        self.reload()
        while True:
            self.draw()
            try:
                key = self.screen.get_wch()
            except curses.error:
                self.reload()
                continue
            if key == curses.KEY_RESIZE:
                continue
            action = self.handle_key(key)
            if action == "quit":
                return
            if action == "open" and self.open_selected():
                return


def relative_age(timestamp):
    if timestamp == float("inf"):
        return "now"
    if not timestamp:
        return "—"
    seconds = max(0, time.time() - timestamp)
    for unit, size in (("d", 86400), ("h", 3600), ("m", 60)):
        if seconds >= size:
            return f"{int(seconds // size)}{unit}"
    return "now"


def fit(text, width):
    if len(text) <= width:
        return text.ljust(width)
    return text[: max(0, width - 1)] + "…"


def fit_left(text, width):
    if len(text) <= width:
        return text
    return "…" + text[-(width - 1):]


def launch_rename_worker(pane_id, name=None):
    """Detached so a busy Claude can apply /rename after the picker closes."""
    worker = Path(__file__).with_name("rename_worker.py")
    args = [sys.executable, str(worker), pane_id] + ([name] if name else [])
    subprocess.Popen(
        args,
        cwd=worker.parent,
        start_new_session=True,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def main(screen):
    curses.start_color()
    curses.use_default_colors()
    selection_bg = 8 if curses.COLORS >= 16 else curses.COLOR_BLUE
    foregrounds = {
        0: -1,
        1: curses.COLOR_YELLOW,
        2: curses.COLOR_RED,
        3: curses.COLOR_GREEN,
        4: curses.COLOR_CYAN,
        5: curses.COLOR_MAGENTA,
        PAIR_ACCENT: curses.COLOR_CYAN,
    }
    for pair, foreground in foregrounds.items():
        if pair:
            curses.init_pair(pair, foreground, -1)
        curses.init_pair(pair + SELECTED_OFFSET, foreground, selection_bg)
    curses.init_pair(PAIR_KEY, curses.COLOR_BLACK, curses.COLOR_CYAN)
    curses.init_pair(PAIR_CHIP, curses.COLOR_BLACK, curses.COLOR_CYAN)
    Picker(screen).run()


if __name__ == "__main__":
    curses.wrapper(main)
