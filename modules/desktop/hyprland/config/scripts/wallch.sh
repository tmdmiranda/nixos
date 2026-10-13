#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="${wallpaper_path:-$HOME/.local/share/walls}"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/wallch"
mkdir -p -- "$state_dir"
wallpaper_index_file="$state_dir/wallpaper_index"

# Serialize cycling and daemon startup when the key binding is pressed rapidly.
exec 9>"$state_dir/lock"
flock -x 9

[[ -d "$wallpaper_dir" ]] || { printf 'Wallpaper directory does not exist: %s\n' "$wallpaper_dir" >&2; exit 1; }
# NUL delimiters preserve spaces and other special characters in filenames.
wallpaper_list=$(mktemp "$state_dir/list.XXXXXX")
trap 'rm -f -- "$wallpaper_list"' EXIT
find "$wallpaper_dir" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.mp4' \) -print0 | sort -z > "$wallpaper_list"
mapfile -d '' -t wallpapers < "$wallpaper_list"
((${#wallpapers[@]})) || { printf 'No wallpapers found in %s\n' "$wallpaper_dir" >&2; exit 1; }

current_index=0
if [[ -f "$wallpaper_index_file" ]]; then
    current_index=$(cat -- "$wallpaper_index_file")
elif [[ -f "$HOME/.config/hypr/wallpaper_index" ]]; then
    # Read the old index once, without writing into the config directory.
    current_index=$(cat -- "$HOME/.config/hypr/wallpaper_index")
fi
# Reject corrupt or excessively large values before using shell arithmetic.
if [[ ! "$current_index" =~ ^[0-9]{1,9}$ ]]; then
    current_index=0
fi
next_index=$(( (10#$current_index + 1) % ${#wallpapers[@]} ))
next_wallpaper="${wallpapers[$next_index]}"

if [[ "${next_wallpaper,,}" == *.mp4 ]]; then
    MONITOR=$(hyprctl monitors | awk '/Monitor/{print $2; exit}')
    [[ -n "$MONITOR" ]] || { printf 'No monitor detected.\n' >&2; exit 1; }
    pkill -x mpvpaper 2>/dev/null || true
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
    pkill -x mpvpaper 2>/dev/null || true
    awww img "$next_wallpaper" --transition-fps 244 --transition-type simple --transition-duration 1
fi

# Commit the index only after the wallpaper command succeeds.
printf '%s\n' "$next_index" > "$wallpaper_index_file.tmp"
mv -f -- "$wallpaper_index_file.tmp" "$wallpaper_index_file"

