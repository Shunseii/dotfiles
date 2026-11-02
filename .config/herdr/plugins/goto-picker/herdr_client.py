"""Minimal client for the herdr socket API plus shared focus-history storage."""

import json
import os
import socket
import time
from pathlib import Path

HISTORY_LIMIT = 500


def request(method, params=None):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(5)
    sock.connect(os.environ["HERDR_SOCKET_PATH"])
    try:
        payload = {"id": f"goto-{method}", "method": method, "params": params or {}}
        sock.sendall((json.dumps(payload) + "\n").encode())
        buf = b""
        while not buf.endswith(b"\n"):
            chunk = sock.recv(65536)
            if not chunk:
                break
            buf += chunk
    finally:
        sock.close()
    response = json.loads(buf.decode())
    if "error" in response:
        raise RuntimeError(response["error"].get("message", str(response["error"])))
    return response["result"]


def snapshot():
    return request("session.snapshot")["snapshot"]


def history_path():
    state_dir = os.environ.get("HERDR_PLUGIN_STATE_DIR") or os.path.expanduser(
        "~/.local/state/herdr-goto"
    )
    Path(state_dir).mkdir(parents=True, exist_ok=True)
    return Path(state_dir) / "history.json"


def load_history():
    try:
        return json.loads(history_path().read_text())
    except (OSError, ValueError):
        return {"panes": {}, "tabs": {}}


def save_history(history):
    for key in ("panes", "tabs"):
        entries = history.get(key, {})
        if len(entries) > HISTORY_LIMIT:
            newest = sorted(entries.items(), key=lambda kv: kv[1], reverse=True)
            history[key] = dict(newest[:HISTORY_LIMIT])
    path = history_path()
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(history))
    tmp.replace(path)


def touch(pane_id=None, tab_id=None):
    history = load_history()
    now = time.time()
    if pane_id:
        history.setdefault("panes", {})[pane_id] = now
    if tab_id:
        history.setdefault("tabs", {})[tab_id] = now
    save_history(history)


def load_prefs():
    try:
        return json.loads((history_path().parent / "prefs.json").read_text())
    except (OSError, ValueError):
        return {}


def save_prefs(prefs):
    (history_path().parent / "prefs.json").write_text(json.dumps(prefs))
