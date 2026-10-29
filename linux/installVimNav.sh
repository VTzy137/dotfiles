#!/bin/bash
# Install vimnav for Linux: python3-evdev, access to keyboards and /dev/uinput,
# and a user service that runs linux/vimnav.py now and at login.
# Usage: bash linux/installVimNav.sh
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Dependencies (notify-send shows NORMAL / INSERT)
sudo apt install -y python3-evdev libnotify-bin

# 2. Let the input group read keyboards and create the virtual mouse
echo 'KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"' |
    sudo tee /etc/udev/rules.d/80-vimnav-uinput.rules > /dev/null
echo uinput | sudo tee /etc/modules-load.d/vimnav-uinput.conf > /dev/null
sudo modprobe uinput
sudo udevadm control --reload-rules
sudo udevadm trigger --name-match=uinput
NEW_GROUP=0
if ! id -nG "$USER" | grep -qw input; then
    sudo usermod -aG input "$USER"
    NEW_GROUP=1
fi

# 3. Start at login; points at the repo copy so edits apply after a restart
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/vimnav.service <<EOF
[Unit]
Description=vimnav: vim-like keyboard mouse

[Service]
ExecStart=/usr/bin/python3 $DIR/vimnav.py
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
EOF
systemctl --user daemon-reload
systemctl --user enable vimnav.service

# 4. Run now, unless the new group needs a fresh login first
if [ "$NEW_GROUP" = 1 ]; then
    echo 'Added you to the input group: reboot, then vimnav starts on its own.'
else
    systemctl --user restart vimnav.service
    echo 'vimnav is running.'
fi
