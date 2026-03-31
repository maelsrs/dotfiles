#!/bin/bash
# Wallpaper selector with rofi (SUPER A)
# Supports images (awww) and videos (mpvpaper)

SCRIPTSDIR="$HOME/.config/hypr/scripts"
wallDIR="$HOME/Pictures/bgs"
LAST_WALL="$HOME/.cache/last_wallpaper"

# Transition config for awww
AWWW_PARAMS="--transition-fps 30 --transition-type wipe --transition-duration 1"

# Retrieve image and video files
PICS=($(ls "${wallDIR}" | grep -iE "\.(jpg|jpeg|png|gif|mp4|mkv|webm)$"))
RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME="${#PICS[@]}. random"

# Rofi command
rofi_command="rofi -show -dmenu -config ~/.config/rofi/config-wallpaper.rasi"

menu() {
  for i in "${!PICS[@]}"; do
    if echo "${PICS[$i]}" | grep -iqE "\.(mp4|mkv|webm)$"; then
      printf "${PICS[$i]} [video]\n"
    elif echo "${PICS[$i]}" | grep -iqE "\.gif$"; then
      printf "${PICS[$i]} [gif]\n"
    else
      printf "$(echo "${PICS[$i]}" | cut -d. -f1)\x00icon\x1f${wallDIR}/${PICS[$i]}\n"
    fi
  done
  printf "$RANDOM_PIC_NAME\n"
  printf "none (disable wallpaper)\n"
}

set_wallpaper() {
  local file="$1"
  echo "$file" > "$LAST_WALL"
  if echo "$file" | grep -iqE "\.(mp4|mkv|webm)$"; then
    pkill mpvpaper 2>/dev/null
    pkill awww-daemon 2>/dev/null
    mpvpaper -f -o "loop" '*' "$file"
  else
    pkill mpvpaper 2>/dev/null
    if ! pgrep -x awww-daemon > /dev/null; then
      awww-daemon &
      sleep 0.5
    fi
    awww img "$file" $AWWW_PARAMS
  fi
}

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
  exit 0
fi

choice=$(menu | ${rofi_command})

# No choice case
if [[ -z $choice ]]; then
  exit 0
fi

# Disable wallpaper
if [ "$choice" = "none (disable wallpaper)" ]; then
  pkill mpvpaper 2>/dev/null
  pkill awww-daemon 2>/dev/null
  echo "none" > "$LAST_WALL"
  exit 0
fi

# Random choice case
if [ "$choice" = "$RANDOM_PIC_NAME" ]; then
  set_wallpaper "${wallDIR}/${RANDOM_PIC}"
  exit 0
fi

# Strip tags like " [video]" or " [gif]"
choice=$(echo "$choice" | sed 's/ \[.*\]$//')

# Find the selected file
for i in "${!PICS[@]}"; do
  filename=$(basename "${PICS[$i]}")
  if [[ "$filename" == "$choice"* ]]; then
    set_wallpaper "${wallDIR}/${PICS[$i]}"
    exit 0
  fi
done

echo "Image not found."
exit 1
