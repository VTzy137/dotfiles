# desc: GNOME: Extension Manager app, animations off, Super+N cycles/minimizes, Super+D overview, Super+Enter opens a terminal
# default: on
# check: dpkg -s gnome-shell-extension-manager && gsettings get org.gnome.shell.keybindings toggle-overview | grep -q "<Super>d" && [ "$(gsettings get org.gnome.shell.extensions.dash-to-dock click-action)" = "'cycle-windows'" ] && [ "$(gsettings get org.gnome.desktop.interface enable-animations)" = false ] && gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | grep -q dotfiles-terminal && gsettings get org.gnome.shell enabled-extensions | grep -q dock-minimize@dotfiles
has gsettings || { warn "no gsettings, skipping"; exit 0; }
# Extension Manager: browse, install and configure GNOME extensions (gTile, Hide Top Bar...)
apt_install gnome-shell-extension-manager
gsettings set org.gnome.desktop.interface enable-animations false
ok "animations off"

# Super+D opens the overview (activities) instead of showing the desktop
gsettings set org.gnome.desktop.wm.keybindings show-desktop "[]"
gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>d']"
ok "Super+D: overview"

# Ubuntu Dock (dash-to-dock): Super+1..9 are handled by the dock, not GNOME's own
# switch-to-application keys. Super+N (or a click) focuses the app; pressing again while it's
# focused cycles to its next window (no window-picker popup)
for i in {1..9}; do gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"; done
if gsettings list-schemas | grep -qx org.gnome.shell.extensions.dash-to-dock; then
    gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys true
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'cycle-windows'
    ok "dock: Super+1..9 hot keys, press again to cycle the app's windows"
    # Our small extension: pressing it again on a focused single-window app minimizes it
    link linux/gnome-extensions/dock-minimize@dotfiles ~/.local/share/gnome-shell/extensions/dock-minimize@dotfiles
    gnome_ext_enable dock-minimize@dotfiles
fi

# Custom shortcut: Super+Enter -> the default terminal (Ptyxis)
if has xdg-terminal-exec; then term="xdg-terminal-exec"
elif has ptyxis; then term="ptyxis --new-window"
else term="x-terminal-emulator"; fi
base=org.gnome.settings-daemon.plugins.media-keys
path=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/dotfiles-terminal/
list="$(gsettings get $base custom-keybindings)"
if [[ "$list" != *"$path"* ]]; then
    if [[ "$list" == "@as []" || "$list" == "[]" ]]; then list="['$path']"; else list="${list%]}, '$path']"; fi
    gsettings set $base custom-keybindings "$list"
fi
kb="$base.custom-keybinding:$path"
gsettings set "$kb" name "Terminal"
gsettings set "$kb" command "$term"
gsettings set "$kb" binding "<Super>Return"
ok "Super+Enter opens: $term"
