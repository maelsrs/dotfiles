#!/bin/bash
# Restore last wallpaper on boot

LAST_WALL="$HOME/.cache/last_wallpaper"
AWWW_PARAMS="--transition-fps 30 --transition-type wipe --transition-duration 1"

if [[ ! -f "$LAST_WALL" ]]; then
  awww query || awww init
  exit 0
fi

file=$(cat "$LAST_WALL")

if [[ "$file" == "none" ]]; then
  exit 0
fi

if [[ ! -f "$file" ]]; then
  awww query || awww init
  exit 0
fi

if echo "$file" | grep -iqE "\.(mp4|mkv|webm)$"; then
  mpvpaper -f -o "loop" '*' "$file"
else
  awww-daemon &
  sleep 0.5
  awww img "$file" $AWWW_PARAMS
fi
