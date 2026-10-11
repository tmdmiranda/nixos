#!/usr/bin/env bash

# Directory containing wallpapers
wallpaper_dir="${wallpaper_path:-$HOME/.local/share/walls}"

# File to store the current position in the wallpaper list
wallpaper_index_file="$HOME/.config/hypr/wallpaper_index"

# Get the list of wallpapers in the specified directory (sorted alphabetically)
wallpapers=($(find "$wallpaper_dir" -type f -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" -o -name "*.mp4" | sort))

# Get the current index (default to 0 if no index file exists)
current_index=0
if [[ -f "$wallpaper_index_file" ]]; then
    current_index=$(cat "$wallpaper_index_file")
fi

# Cycle to the next wallpaper
next_index=$(( (current_index + 1) % ${#wallpapers[@]} ))

# Get the next wallpaper
next_wallpaper="${wallpapers[$next_index]}"

# Save the new index to the file
echo "$next_index" > "$wallpaper_index_file"

# Check if the next wallpaper is a video or an image
if [[ "$next_wallpaper" == *.mp4 ]]; then
    # Kill any existing mpvpaper instances
    pkill mpvpaper
    # Use mpvpaper for video wallpapers (loop indefinitely)
    MONITOR=$(hyprctl monitors | awk '/Monitor/{print $2; exit}') # First monitor detected
    mpvpaper -o "loop-playlist=inf" "$MONITOR" "$next_wallpaper" &
else
  pkill mpvpaper 2>/dev/null
  trans_type="simple"

  if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.2
  fi

  awww img "$next_wallpaper" --transition-fps 244 --transition-type "$trans_type" --transition-duration 1
fi
