# desc: VS Code from Microsoft's apt repo + settings/keybindings from vscode/
# default: off
# check: has code && [ -L ~/.config/Code/User/settings.json ]
if ! has code; then
    apt_install wget gpg apt-transport-https
    sudo install -d -m 755 /etc/apt/keyrings
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor |
        sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |
        sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    _APT_UPDATED=
    apt_install code
fi
link vscode/settings.json ~/.config/Code/User/settings.json
link vscode/keybindings.json ~/.config/Code/User/keybindings.json
