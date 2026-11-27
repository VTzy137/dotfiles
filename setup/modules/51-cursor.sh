# desc: Cursor editor (.deb, updates through apt afterwards) + settings from cursor/
# default: on
# check: has cursor && [ -L ~/.config/Cursor/User/settings.json ]
if ! has cursor; then
    tmp="$(mktemp -d)"
    curl -fL -o "$tmp/cursor.deb" "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/latest"
    apt_update
    sudo apt-get install -y "$tmp/cursor.deb"
    rm -rf "$tmp"
fi
link cursor/settings.json ~/.config/Cursor/User/settings.json
link cursor/keybindings.json ~/.config/Cursor/User/keybindings.json
