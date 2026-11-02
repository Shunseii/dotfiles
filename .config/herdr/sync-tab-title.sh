#!/usr/bin/env bash
#
# Sync the focused pane's coding-agent session name to its herdr tab label.
# Bound to a key via [[keys.command]] (type = "shell") in config.toml, so it can
# be triggered on demand — e.g. after renaming the session inside the agent.
#
# type = "shell" runs DETACHED, so there is no calling pane: `herdr pane current
# --current` resolves to nothing. The pane is taken from HERDR_ACTIVE_PANE_ID
# when herdr provides one, else from the snapshot's focused pane.
#
# Name sources per agent:
#   claude -> ~/.claude/sessions/<pid>.json "name" (honors `claude -n` and
#             /rename); pid comes from the pane's foreground processes
#   pi     -> the pane's terminal title, which pi sets to
#             "<app> - <session name> - <cwd basename>" when named and
#             "<app> - <cwd basename>" when not (honors `pi -n` and /name).
#             pi writes its session file lazily, so the title is the only
#             source that works before the first message.
#   omp    -> the pane's terminal title, which omp sets to
#             "π <sep> <label>" where <sep> is ">" (idle), "!" (attention),
#             or a braille spinner character (working). When title state is
#             disabled: "π: <label>" or bare "π" (no label). Never includes cwd.
#
# No-op unless the focused pane runs a named session of either agent.
# Set SYNC_TAB_TITLE_DEBUG=1 to append diagnostics to /tmp/sync-tab-title.log.
set -euo pipefail

herdr="${HERDR_BIN_PATH:-herdr}"

snapshot=$("$herdr" api snapshot 2>/dev/null) || exit 0

# Resolve the target pane, then look it up in the snapshot's agent list, which
# carries the agent kind, tab id, cwd, and spinner-stripped terminal title.
# Tab-separated because cwd basenames and titles both contain spaces.
#
# HERDR_ACTIVE_PANE_ID is the canonical source when Herdr sets it for detached
# shell commands. HERDR_PANE_ID is NOT used — it persists in subprocess env and
# goes stale when the user switches focus. The snapshot's focused_pane_id is the
# reliable fallback.
IFS=$'\t' read -r pane tab agent cwd_name title < <(printf '%s' "$snapshot" | python3 -c '
import json, os, sys

snap = json.load(sys.stdin)["result"]["snapshot"]
pane = os.environ.get("HERDR_ACTIVE_PANE_ID") or snap.get("focused_pane_id") or ""
for entry in snap.get("agents", []):
    if entry.get("pane_id") == pane:
        print("\t".join([pane, entry.get("tab_id", "") or "", entry.get("agent", "") or "",
                         os.path.basename(entry.get("cwd", "") or ""),
                         entry.get("terminal_title_stripped", "") or ""]))
        break
') || exit 0
[ -n "${pane:-}" ] && [ -n "${tab:-}" ] && [ -n "${agent:-}" ] || exit 0

case "$agent" in
  claude)
    pinfo=$("$herdr" pane process-info --pane "$pane" 2>/dev/null) || exit 0
    name=$(printf '%s' "$pinfo" | python3 -c '
import json, os, sys

def session_name(pid):
    path = os.path.expanduser("~/.claude/sessions/%s.json" % pid)
    with open(path, encoding="utf-8") as f:
        return json.load(f).get("name")

try:
    procs = json.load(sys.stdin)["result"]["process_info"].get("foreground_processes", [])
    name = next((session_name(p["pid"]) for p in procs
                 if os.path.basename((p.get("argv") or [""])[0]) == "claude"), None)
    print(name if isinstance(name, str) and name.strip() else "")
except Exception:
    print("")
')
    ;;
  pi)
    # "<app> - <name> - <cwd>" is named; "<app> - <cwd>" is not.
    name=$(TITLE="$title" python3 -c '
import os
parts = os.environ["TITLE"].split(" - ")
print(" - ".join(parts[1:-1]) if len(parts) >= 3 else "")
')
    ;;
  omp)
    # Title format: "π <sep> <label>" — <sep> is ">" (idle), "!" (attention),
    # or a braille spinner char (working). Also handles "π: <label>" (disabled).
    # Bare "π" or "π <sep>" with no label produce no name.
    name=$(TITLE="$title" CWD_NAME="$cwd_name" python3 -c '
import os, re
title = os.environ["TITLE"].strip()
# Match "π" then an optional single non-alphanumeric separator, then the label.
# Label must contain at least one word character so "π >" does not match.
m = re.match(r"^π\s*[^a-zA-Z0-9]?\s*(\w.*)", title)
label = m.group(1).strip() if m else ""
# Only produce a name when it is not just the cwd basename
print(label if label and label != os.environ.get("CWD_NAME") else "")
')
    ;;
  *)
    exit 0
    ;;
esac

if [ "${SYNC_TAB_TITLE_DEBUG:-}" = 1 ]; then
  printf '%s pane=%s tab=%s agent=%s title=%q name=%q\n' \
    "$(date -Is)" "$pane" "$tab" "$agent" "$title" "${name:-}" \
    >> /tmp/sync-tab-title.log
fi

[ -n "${name:-}" ] || exit 0

exec "$herdr" tab rename "$tab" "$name"
