# desc: Ptyxis (Ubuntu's terminal) as the default terminal: pixegami colours + Roboto Mono Powerline, opens in tmux
# default: on
# check: has ptyxis && [ -L ~/.local/share/org.gnome.Ptyxis/palettes/pixegami.palette ] && grep -q Ptyxis ~/.config/xdg-terminals.list
apt_install ptyxis dconf-cli
# Colours: a palette file Ptyxis lists by its file name ("pixegami")
link .config/ptyxis/pixegami.palette ~/.local/share/org.gnome.Ptyxis/palettes/pixegami.palette
profile="$(gsettings get org.gnome.Ptyxis default-profile-uuid | tr -d "'")"
dconf write "/org/gnome/Ptyxis/Profiles/$profile/palette" "'pixegami'"
# Font the pixegami-agnoster theme was made for (installed by the zsh module)
gsettings set org.gnome.Ptyxis use-system-font false
gsettings set org.gnome.Ptyxis font-name 'Roboto Mono for Powerline 12'

# Default terminal for xdg-terminal-exec (what Ctrl+Alt+T, Super+Enter and "open in terminal" use).
# Ubuntu checks ubuntu-xdg-terminals.list first; ~/.config wins over the system lists.
# tmux is started by .zshrc, so every window opens in tmux.
for list in ubuntu-xdg-terminals.list xdg-terminals.list; do
    printf 'org.gnome.Ptyxis.desktop:new-window\n' > ~/.config/$list
done
ok "Ptyxis is the default terminal (pixegami colours, opens in tmux)"
