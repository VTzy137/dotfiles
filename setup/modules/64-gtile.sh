# desc: gTile window tiling grid (GNOME extension, Super+G) + settings from gnome/gtile.dconf
# default: on
# check: [ -d ~/.local/share/gnome-shell/extensions/gTile@vibou ] && gsettings get org.gnome.shell enabled-extensions | grep -q gTile@vibou
has gnome-shell || { warn "not GNOME, skipping"; exit 0; }
apt_install gnome-shell-extension-prefs curl dconf-cli
gnome_ext_install gTile@vibou

# Your gTile settings. Save changes back with:
#   dconf dump /org/gnome/shell/extensions/gtile/ > gnome/gtile.dconf
if [ -s "$DOTFILES/gnome/gtile.dconf" ]; then
    dconf load /org/gnome/shell/extensions/gtile/ < "$DOTFILES/gnome/gtile.dconf"
    ok "gTile settings loaded"
fi
# Super+Enter opens the terminal (gnome module), so the grid moves to Super+G
ext_gset gTile@vibou org.gnome.shell.extensions.gtile show-toggle-tiling "['<Super>g']"
ok "gTile: Super+G opens the grid"
