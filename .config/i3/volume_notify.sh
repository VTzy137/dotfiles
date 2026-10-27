#!/bin/zsh
# Adjust volume and display notification

# Check if an argument is provided
if [[ "$1" == "up" ]]; then
    # Increase volume by 2%
    pactl set-sink-volume @DEFAULT_SINK@ +2%
elif [[ "$1" == "down" ]]; then
    # Decrease volume by 2%
    pactl set-sink-volume @DEFAULT_SINK@ -2%
else
    echo "Usage: $0 {up|down}"
    exit 1
fi

dunstctl close-all
# Get current volume level
# VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '/Front/{print $5}')
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@)
# ALT_VOLUME=$(echo "$VOLUME" | awk '/front-left/ {print $5}')
# Send notification with current volume level
notify-send "Volume" "$VOLUME" -t 2500 
# if [[ "$1" == "up" ]]; then
#     notify-send "Volume" "Increase Volume\nCurrent Volume: $VOLUME" -t 1500 
#      # Increase volume by 5%
# elif [[ "$1" == "down" ]]; then
#     notify-send "Volume" "Decrease Volume\nCurrent Volume: $VOLUME" -t 1500 
#     # Decrease volume by 5%
# fi   
# notify-send "Volume" "Increase Volume\nCurrent Volume: $ALT_VOLUME"

