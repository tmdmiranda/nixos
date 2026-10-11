#!/usr/bin/env bash
# All-in-one wifi module: signal icon on the bar; hover shows own connection,
# a separator, then cached LAN peers. Click rescans the LAN (lan peers only;
# own status always reads live via nmcli, no radio hit).
CACHE="$HOME/.cache/waybar-lan.txt"

rescan() {
  local iface cidr tmp mactmp
  iface=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+')
  cidr=$(ip -o -f inet addr show "$iface" 2>/dev/null | grep -oP 'inet \K\S+')
  [ -z "$cidr" ] && exit 0
  tmp=$(mktemp)
  mactmp=$(mktemp)
  nmap -sn -T4 "$cidr" 2>/dev/null > "$tmp.raw"
  # Unprivileged nmap can't see MACs — merge the now-warm ARP table instead.
  ip -o neigh show > "$mactmp"
  {
    echo "LAN ($(date +%H:%M))"
    awk '
      FNR == NR { if ($5 ~ /:/) m[$1] = $5; next }
      /^Nmap scan report for/ {
        if (pending != "") print pending
        if (NF == 6) { ip = $6; gsub(/[()]/, "", ip); host = $5 } else { ip = $5; host = "-" }
        mac = (ip in m) ? m[ip] : "-"
        pending = sprintf("%-15s %-17s %s", ip, mac, host)
      }
      END { if (pending != "") print pending }' "$mactmp" "$tmp.raw"
  } > "$tmp"
  rm -f "$tmp.raw" "$mactmp"
  mkdir -p "$(dirname "$CACHE")"
  mv "$tmp" "$CACHE"
}

show() {
  local info ssid sig icon iface ip gw tooltip esc
  info=$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "*" { print $2 "|" $3; exit }')
  iface=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+')
  ip=$(ip -o -f inet addr show "$iface" 2>/dev/null | grep -oP 'inet \K\S+')
  gw=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'via \K\S+')
  if [ -n "$info" ]; then
    ssid=${info%%|*}
    sig=${info##*|}
    if   [ "${sig:-0}" -ge 80 ]; then icon=$'\U000F0928'
    elif [ "${sig:-0}" -ge 60 ]; then icon=$'\U000F0925'
    elif [ "${sig:-0}" -ge 40 ]; then icon=$'\U000F0922'
    elif [ "${sig:-0}" -ge 20 ]; then icon=$'\U000F091F'
    else icon=$'\U000F092F'; fi
    tooltip="$ssid ($sig%)"$'\n'"$ip via $gw"
  elif [ -n "$iface" ]; then
    icon=$'\uf233'
    tooltip="$iface"$'\n'"$ip via $gw"
  else
    icon=$'\U000F092E'
    tooltip="Disconnected"
  fi
  if [ -n "$iface" ]; then
    tooltip="$tooltip"$'\n'"------------------------"
    if [ -f "$CACHE" ]; then
      tooltip="$tooltip"$'\n'"$(cat "$CACHE")"
    else
      tooltip="$tooltip"$'\n'"Click to rescan LAN"
    fi
  fi
  esc=${tooltip//\\/\\\\}
  esc=${esc//\"/\\\"}
  esc=${esc//$'\n'/\\n}
  printf '{"text": "%s", "tooltip": "%s"}\n' "$icon" "$esc"
}

if [ "${1:-}" = "--rescan" ]; then
  rescan
fi
show
