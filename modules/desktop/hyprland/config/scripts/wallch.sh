#!/usr/bin/env bash
set -euo pipefail

if (($# > 1)) || [[ "${1:-}" != "" && "$1" != --restore ]]; then
    printf 'Usage: %s [--restore]\n' "$0" >&2
    exit 1
fi

wallpaper_dir="${wallpaper_path:-$HOME/.local/share/walls}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/wallch"
mkdir -p -- "$state_dir"
wallpaper_file="$state_dir/current_wallpaper"

# Serialize cycling and daemon startup when the key binding is pressed rapidly.
exec 9>"$state_dir/lock"
flock -x 9

# Nix runs mpvpaper as .mpvpaper-wrapped, so matching only the process
# name "mpvpaper" misses it. Match the executable in the full command line.
# Stop players before scanning files or waiting for awww to become ready.
player_pattern='(^|/)[.]?mpvpaper(-wrapped)?([[:space:]]|$)'
player_pids() {
    local pid status
    while read -r pid; do
        [[ -n "$pid" ]] || continue
        status=$(ps -o stat= -p "$pid" 2>/dev/null) || continue
        # Zombies have already released their surfaces and cannot be killed.
        [[ "$status" == *Z* ]] || printf '%s\n' "$pid"
    done <<< "$(pgrep -u "$(id -u)" -f "$player_pattern" || true)"
}
old_players=()
while read -r pid; do
    [[ -z "$pid" ]] || old_players+=("$pid")
done <<< "$(player_pids)"
if ((${#old_players[@]})); then
    kill -TERM "${old_players[@]}" 2>/dev/null || true
    for ((attempt=0; attempt<10; attempt++)); do
        live_players=()
        for pid in "${old_players[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                live_players+=("$pid")
            fi
        done
        ((${#live_players[@]})) || break
        sleep 0.05
    done
    # A stuck decoder must not leave an old wallpaper covering the new one.
    if ((${#live_players[@]})); then
        kill -KILL "${live_players[@]}" 2>/dev/null || true
        for ((attempt=0; attempt<20; attempt++)); do
            if [[ -z "$(player_pids)" ]]; then
                break
            fi
            sleep 0.05
        done
        if [[ -n "$(player_pids)" ]]; then
            printf 'Previous mpvpaper processes have not exited.\n' >&2
            exit 1
        fi
    fi
fi

[[ -d "$wallpaper_dir" ]] || { printf 'Wallpaper directory does not exist: %s\n' "$wallpaper_dir" >&2; exit 1; }
wallpaper_dir=$(realpath -e -- "$wallpaper_dir")
# NUL delimiters preserve spaces and other special characters in filenames.
wallpaper_list=$(mktemp "$state_dir/list.XXXXXX")
trap 'rm -f -- "$wallpaper_list"' EXIT
find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.mp4' \) -print0 | sort -z > "$wallpaper_list"
mapfile -d '' -t wallpapers < "$wallpaper_list"
((${#wallpapers[@]})) || { printf 'No wallpapers found in %s\n' "$wallpaper_dir" >&2; exit 1; }

current_index=-1
if [[ -f "$wallpaper_file" ]]; then
    # NUL termination preserves even trailing newlines in filenames.
    IFS= read -r -d '' current_wallpaper < "$wallpaper_file" || true
    for i in "${!wallpapers[@]}"; do
        if [[ "${wallpapers[$i]}" == "$current_wallpaper" ]]; then
            current_index=$i
            break
        fi
    done
else
    # Migrate the old index only until a path has been saved successfully.
    for index_file in "$state_dir/wallpaper_index" "$HOME/.config/hypr/wallpaper_index"; do
        [[ -f "$index_file" ]] || continue
        legacy_index=$(cat -- "$index_file")
        if [[ "$legacy_index" =~ ^[0-9]{1,9}$ ]] && ((10#$legacy_index < ${#wallpapers[@]})); then
            current_index=$((10#$legacy_index))
        fi
        break
    done
fi
next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))
if [[ "${1:-}" == --restore ]] && ((current_index >= 0)); then
    next_index=$current_index
fi
next_wallpaper="${wallpapers[$next_index]}"

if [[ "${next_wallpaper,,}" == *.mp4 ]]; then
    MONITOR=$(hyprctl monitors | awk '/Monitor/{print $2; exit}')
    [[ -n "$MONITOR" ]] || { printf 'No monitor detected.\n' >&2; exit 1; }
    mpvpaper -o 'loop-playlist=inf' "$MONITOR" "$next_wallpaper" 9>&- &
else
    # Ask the daemon on this session's socket instead of checking process names.
    if ! awww query >/dev/null 2>&1; then
        awww-daemon >"$state_dir/daemon.log" 2>&1 9>&- &
        ready=false
        for ((attempt=0; attempt<50; attempt++)); do
            if awww query >/dev/null 2>&1; then
                ready=true
                break
            fi
            sleep 0.1
        done
        if [[ "$ready" != true ]]; then
            printf 'awww-daemon did not become ready; see %s/daemon.log\n' "$state_dir" >&2
            exit 1
        fi
    fi
    awww img "$next_wallpaper" --transition-fps 244 --transition-type simple --transition-duration 1
fi

# Commit the path only after the wallpaper command succeeds.
printf '%s\0' "$next_wallpaper" > "$wallpaper_file.tmp"
mv -f -- "$wallpaper_file.tmp" "$wallpaper_file"
