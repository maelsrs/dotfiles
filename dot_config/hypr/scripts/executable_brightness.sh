#!/bin/bash
# Rofi brightness slider

roconf="$HOME/.config/rofi/config.rasi"
current=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

options="100%\n90%\n80%\n70%\n60%\n50%\n40%\n30%\n20%\n10%\n5%"

chosen=$(echo -e "$options" | rofi -dmenu -theme-str "entry { placeholder: \"Brightness: ${current}%\";}" -config "$roconf" -p "Brightness")

[ -z "$chosen" ] && exit 0

brightnessctl set "$chosen"
