"""Event hook: record pane/tab focus times for the picker's recent-first sort."""

import json
import os

import herdr_client


def find_key(node, key):
    if isinstance(node, dict):
        if isinstance(node.get(key), str):
            return node[key]
        for value in node.values():
            found = find_key(value, key)
            if found:
                return found
    elif isinstance(node, list):
        for value in node:
            found = find_key(value, key)
            if found:
                return found
    return None


def main():
    try:
        event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON") or "{}")
    except ValueError:
        event = {}
    pane_id = find_key(event, "pane_id")
    tab_id = find_key(event, "tab_id")
    if not pane_id:
        try:
            pane_id = herdr_client.snapshot().get("focused_pane_id")
        except Exception:
            pane_id = None
    herdr_client.touch(pane_id=pane_id, tab_id=tab_id)


if __name__ == "__main__":
    main()
