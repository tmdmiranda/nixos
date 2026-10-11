#!/bin/bash

# Configuration
videos_dir="$HOME/Videos"
mkdir -p "$videos_dir"

# Check if wf-recorder is already running
if pgrep -x "wf-recorder" > /dev/null; then
    pkill -INT -x wf-recorder
    notify-send -t 1000 "Screen Recording" "Recording stopped"
    exit 0
fi

# Countdown and start recording
notify-send -t 1000 "Screen Recording" "Recording starts in 3 seconds..."

sleep 1
notify-send -t 1000 "Screen Recording" "Recording starts in 2 seconds..."

sleep 1  
notify-send -t 1000 "Screen Recording" "Recording starts in 1 second..."

sleep 1

# Generate filename with timestamp
timestamp=$(date +"%Y%m%d-%H%M%S")
recording_file="$videos_dir/recording_$timestamp.mp4"

# Start recording
notify-send -t 2000 "Screen Recording" "Recording started..."
wf-recorder -f "$recording_file"
