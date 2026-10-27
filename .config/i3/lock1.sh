#!/usr/bin/env bash

alpha='99'
beta='80'
background='#282a36'
selection='#44475a'
comment='#6272a4'

yellow='#f1fa8c'
orange='#ffb86c'
red='#ff5555'
magenta='#ff79c6'
blue='#6272a4'
cyan='#8be9fd'
green='50fa7b'

WALLPAPER="${1:-$HOME/Pictures/wallpaper/737474.png}"
LOCK_IMG=()
if [ -f "$WALLPAPER" ]; then
  LOCK_IMG=(-i "$WALLPAPER")
fi

i3lock "${LOCK_IMG[@]}" \
  -c 373445ff \
  --insidever-color=$selection \
  --insidewrong-color=$selection$alpha \
  --inside-color=$selection$alpha \
  --ringver-color=$green$alpha \
  --ringwrong-color=$red$alpha \
  --ringver-color=$green$alpha \
  --ringwrong-color=$red$alpha \
  --ring-color=$blue$alpha \
  --line-uses-ring \
  --keyhl-color=$cyan$alpha \
  --bshl-color=$cyan$alpha \
  --separator-color=$selection$alpha \
  --verif-color=$green \
  --wrong-color=$red$beta \
  --modif-color=$red$beta \
  --layout-color=$blue \
  --date-color=$cyan \
  --time-color=$cyan \
  --screen 1 \
  --blur 1 \
  --clock \
  --indicator \
  --time-str="%H:%M:%S" \
  --time-size=16\
  --date-str="%A %e %B %Y"\
  --date-size=14\
  --verif-text="Checking..." \
  --verif-size=16\
  --wrong-text="Wrong" \
  --noinput="Empty" \
  --lock-text="Locking..." \
  --lockfailed="Lock Failed" \
  --radius=100 \
  --ring-width=8 \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys \
#  --time-font="JetBrainsMono Nerd Font" \
#  --date-font="JetBrainsMono Nerd Font" \
#  --layout-font="JetBrainsMono Nerd Font" \
#  --verif-font="JetBrainsMono Nerd Font" \
#  --wrong-font="JetBrainsMono Nerd Font" \
while pgrep -x i3lock > /dev/null; do
  sleep 1
done
# sudo brightnessctl set 100%
# These last five lines are commented because they concern the font you want to use.
# JetBrainsMono Nerd Font is the font that was used in the screenshot.
# To specify a favorite font, just uncomment the five lines and replace the parameter with the font you prefer.
