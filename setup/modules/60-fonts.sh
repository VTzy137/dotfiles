# desc: FiraCode Nerd Font (for terminal and editors)
# default: on
# check: ls ~/.local/share/fonts/FiraCodeNerd/*.ttf
dir=~/.local/share/fonts/FiraCodeNerd
if [ -n "$(ls "$dir"/*.ttf 2> /dev/null)" ]; then
    ok "FiraCode Nerd Font already installed"
else
    apt_install unzip fontconfig
    tmp="$(mktemp -d)"
    curl -fL -o "$tmp/FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    mkdir -p "$dir"
    unzip -qo "$tmp/FiraCode.zip" '*.ttf' -d "$dir"
    rm -rf "$tmp"
    fc-cache -f > /dev/null
    ok "FiraCode Nerd Font"
fi
