#!/usr/bin/env bash
set -euo pipefail

log="$HOME/.local/share/Steam/logs/connection_log.txt"
since=0
if ! pgrep -u "$UID" -x steam >/dev/null; then
    since=$(date +%s)
fi
nvidia-offload steam -silent &

for ((i=0; i<30; i++)); do
    if pgrep -u "$UID" -x steam >/dev/null &&
       [[ -f "$log" && ! -e "$HOME/.steam/starting" ]] &&
       (( $(stat -c %Y -- "$log") >= since )) &&
       grep -E '\[[^]]+, [0-9]+, [0-9]+\]' -- "$log" | tail -n 1 | grep -q '\[Logged On,'; then
        break
    fi
    sleep 1
done

export WALLPIPER_CAPTURE_RENDER_NODE=226:128
export WALLPIPER_PROTON_BIN="$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton11-6-x86_64/proton"
exec wallpiperd
