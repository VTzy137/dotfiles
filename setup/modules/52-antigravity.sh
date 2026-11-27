# desc: Google Antigravity editor + `agy` command + settings from antigravity/
# default: on
# check: dpkg -s antigravity && [ -e ~/.local/bin/agy ] && [ -L ~/.config/Antigravity/User/settings.json ]
if ! dpkg -s antigravity > /dev/null 2>&1; then
    sudo install -d -m 755 /etc/apt/keyrings
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor |
        sudo tee /etc/apt/keyrings/antigravity-repo-key.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" |
        sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
    _APT_UPDATED=
    apt_install antigravity
fi
# The package ships only `antigravity`; add the short `agy` name
if ! has agy; then
    mkdir -p ~/.local/bin
    ln -sf /usr/share/antigravity/bin/antigravity ~/.local/bin/agy
    ok "agy -> antigravity (in ~/.local/bin)"
fi
link antigravity/settings.json ~/.config/Antigravity/User/settings.json
link antigravity/keybindings.json ~/.config/Antigravity/User/keybindings.json
