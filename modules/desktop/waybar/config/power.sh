#!/usr/bin/env bash
# plug:/bat: label keyed off the AC ADAPTER (not battery state — the kernel
# sticks at "Not charging" on conservation mode even while plugged in).
ac_online=$(cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo 0)
cap=$(cat /sys/class/power_supply/BAT1/capacity 2>/dev/null || echo "?")

if [ "$ac_online" = "1" ]; then
  printf '{"text": "<span color="#f0c574">plug:</span> %s%%", "class": "plugged"}\n' "$cap"
else
  printf '{"text": "<span color="#f0c574">bat:</span> %s%%", "class": "discharging"}\n' "$cap"
fi
