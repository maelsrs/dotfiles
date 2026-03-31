#!/usr/bin/env sh

ScrDir=`dirname "$(realpath "$0")"`
source $ScrDir/globalcontrol.sh
roconf="~/.config/rofi/clipboard.rasi"


# read hypr theme border

wind_border=$(( hypr_border * 2 ))
elem_border=`[ $hypr_border -eq 0 ] && echo "10" || echo $(( hypr_border * 2 ))`
r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"


# read hypr font size

fnt_override=`gsettings get org.gnome.desktop.interface font-name | awk '{gsub(/'\''/,""); print $NF}'`
fnt_override="configuration {font: \"JetBrainsMono Nerd Font ${fnt_override}\";}"


# clipboard action

case $1 in
    c)  cliphist list | rofi -dmenu -theme-str "entry { placeholder: \"Copy...\";}" -theme-str "${r_override}" -theme-str "${fnt_override}" -config $roconf | cliphist decode | wl-copy
        ;;
    d)  cliphist list | rofi -dmenu -theme-str "entry { placeholder: \"Delete...\";}" -theme-str "${r_override}" -theme-str "${fnt_override}" -config $roconf | cliphist delete
        ;;
    w)  if [ `echo -e "Yes\nNo" | rofi -dmenu -theme-str "entry { placeholder: \"Clear Clipboard History?\";}" -theme-str "${r_override}" -theme-str "${fnt_override}" -config $roconf` == "Yes" ] ; then
            cliphist wipe
        fi
        ;;
    *)  echo -e "cliphist.sh [action]"
        echo "c :  cliphist list and copy selected"
        echo "d :  cliphist list and delete selected"
        echo "w :  cliphist wipe database"
        exit 1
        ;;
esac

