"""Background rename for a Claude pane: run /rename, wait for it to apply, sync the tab.

Usage: rename_worker.py <pane_id> [name]
Without a name, Claude generates one (bare `/rename`). Runs detached from the
picker so it can wait for a busy or slow Claude without blocking the popup.
"""

import json
import os
import subprocess
import sys
import time
from pathlib import Path

import herdr_client

HERDR = os.environ.get("HERDR_BIN_PATH", "herdr")
SYNC_TAB_TITLE = Path.home() / ".config/herdr/sync-tab-title.sh"
CLAUDE_SESSIONS = Path.home() / ".claude/sessions"
# Generous: a busy Claude only runs the queued /rename after its current turn.
TIMEOUT_S = 600
POLL_S = 0.5


def claude_pid(pane_id):
    info = herdr_client.request("pane.process_info", {"pane_id": pane_id})["process_info"]
    for process in info.get("foreground_processes", []):
        if os.path.basename((process.get("argv") or [""])[0]) == "claude":
            return process["pid"]
    return None


def session_name(pid):
    try:
        return json.loads((CLAUDE_SESSIONS / f"{pid}.json").read_text()).get("name")
    except (OSError, ValueError):
        return None


def notify(message):
    subprocess.run(
        [HERDR, "notification", "show", "goto rename", "--body", message],
        capture_output=True,
    )


def main():
    pane_id = sys.argv[1]
    requested = sys.argv[2] if len(sys.argv) > 2 else None
    pid = claude_pid(pane_id)
    if not pid:
        return
    previous = session_name(pid)

    command = f"/rename {requested}" if requested else "/rename"
    subprocess.run([HERDR, "pane", "send-text", pane_id, command], capture_output=True)
    subprocess.run([HERDR, "pane", "send-keys", pane_id, "Enter"], capture_output=True)

    deadline = time.time() + TIMEOUT_S
    while time.time() < deadline:
        current = session_name(pid)
        applied = current == requested if requested else (current and current != previous)
        if applied:
            env = {**os.environ, "HERDR_ACTIVE_PANE_ID": pane_id}
            subprocess.run([str(SYNC_TAB_TITLE)], env=env, capture_output=True)
            return
        if not Path(f"/proc/{pid}").exists():
            return
        time.sleep(POLL_S)
    notify(f"/rename in {pane_id} didn't apply within {TIMEOUT_S // 60} min; run prefix+t after it does")


if __name__ == "__main__":
    main()
