#!/bin/bash
# Switch to workspace, or go back to previous if already on it
target=$1
current=$(hyprctl activeworkspace -j | jq '.id')

if [ "$current" = "$target" ]; then
    hyprctl dispatch workspace previous
else
    hyprctl dispatch workspace "$target"
fi
