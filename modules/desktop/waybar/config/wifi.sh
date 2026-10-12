#!/usr/bin/env bash
# All-in-one wifi module: signal icon on the bar; hover shows own connection,
# a separator, then cached LAN peers. Click rescans the LAN (lan peers only;
# own status always reads live via nmcli, no radio hit).
# Peer discovery is ARP-based (fast, sees firewalled hosts): on a /24 it does
# a ~1-2s parallel ping sweep to populate ARP; on bigger nets (e.g. eduroam)
# it just snapshots the ARP table instead of sweeping thousands of hosts.
CACHE="$HOME/.cache/waybar-lan.txt"

rescan() {
  local iface cidr tmp prefix base i self
  iface=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+')
  cidr=$(ip -o -f inet addr show "$iface" 2>/dev/null | grep -oP 'inet \K\S+')
  [ -z "$cidr" ] && exit 0
  prefix=${cidr#*/}
  self=${cidr%/*}
  if [ "$prefix" = "24" ]; then
    # Small net: ping every address in parallel to (re)populate ARP.
    # ~1-2s total. ARP is L2, so host firewalls don't hide anyone.
    base=${self%.*}
    for i in $(seq 1 254); do
      ping -c1 -W1 -n "$base.$i" >/dev/null 2>&1 &
    done
    wait
  fi
  tmp=$(mktemp)
  {
    echo "LAN $self/$prefix ($(date +%H:%M))"
    while read -r ip mac; do
      [ -z "$ip" ] && continue
      host=$(timeout 2 getent hosts "$ip" 2>/dev/null | awk '{print $2; exit}')
      [ -z "$host" ] && host="-"
      printf "%-15s %-17s %s\n" "$ip" "$mac" "$host"
    done < <(ip -o neigh show | awk -v iface="$iface" '
      {
        # key/value parse: "<ip> [dev <iface>] [lladdr <mac>] <state>"
        # (do not rely on positions; skip entries with no MAC)
        ip = $1
        if (ip !~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ || (ip in seen)) next
        dev = ""; mac = ""
        for (i = 2; i <= NF; i++) {
          if ($i == "dev") dev = $(i+1)
          else if ($i == "lladdr") mac = $(i+1)
        }
        if (dev != "" && dev != iface) next
        if (mac == "") next
        seen[ip] = 1
        print ip, mac
      }' | sort -V)
    # self has no ARP entry — list it for completeness
    host=$(timeout 2 getent hosts "$self" 2>/dev/null | awk '{print $2; exit}')
    [ -z "$host" ] && host=$(hostname)
    printf "%-15s %-17s %s\n" "$self" "-" "$host"
  } > "$tmp"
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
