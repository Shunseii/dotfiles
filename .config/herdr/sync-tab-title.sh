#!/usr/bin/env bash
#
# Sync the focused pane's Claude Code session name to its herdr tab label.
# Bound to a key via [[keys.command]] (type = "shell") in config.toml, so it can
# be triggered on demand — e.g. after `/rename` inside Claude Code.
#
# Reads the *current* display name (honors both `claude -n <name>` and `/rename`)
# from ~/.claude/sessions/<pid>.json. If the focused pane isn't a named Claude
# session, it does nothing.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

cur=$("$herdr" pane current --current 2>/dev/null) || exit 0

read -r pane tab < <(printf '%s' "$cur" | python3 -c '
import json, sys
p = json.load(sys.stdin)["result"]["pane"]
print(p["pane_id"], p["tab_id"])
') || exit 0
[ -n "${pane:-}" ] && [ -n "${tab:-}" ] || exit 0

pinfo=$("$herdr" pane process-info --pane "$pane" 2>/dev/null) || exit 0
pid=$(printf '%s' "$pinfo" | python3 -c '
import json, sys, os
procs = json.load(sys.stdin)["result"]["process_info"].get("foreground_processes", [])
for p in procs:
    argv = p.get("argv") or []
    if argv and os.path.basename(argv[0]) == "claude":
        print(p["pid"]); break
')
[ -n "${pid:-}" ] || exit 0

name=$(python3 -c '
import json, sys, os
try:
    with open(os.path.expanduser("~/.claude/sessions/%s.json" % sys.argv[1]), encoding="utf-8") as f:
        n = json.load(f).get("name")
    print(n if isinstance(n, str) and n.strip() else "")
except Exception:
    print("")
' "$pid")
[ -n "${name:-}" ] || exit 0

exec "$herdr" tab rename "$tab" "$name"
