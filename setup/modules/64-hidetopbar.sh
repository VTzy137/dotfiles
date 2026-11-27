# desc: Hide the top bar (Hide Top Bar extension); move the mouse to the top edge to show it
# default: on
# check: [ -d ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca ] && gsettings get org.gnome.shell enabled-extensions | grep -q hidetopbar@mathieu.bidon.ca
has gnome-shell || { warn "not GNOME, skipping"; exit 0; }
apt_install curl
gnome_ext_install hidetopbar@mathieu.bidon.ca
# Always hidden (not only when a window touches it); shows when the mouse reaches the top edge
ext_gset hidetopbar@mathieu.bidon.ca org.gnome.shell.extensions.hidetopbar enable-intellihide false
ext_gset hidetopbar@mathieu.bidon.ca org.gnome.shell.extensions.hidetopbar mouse-sensitive true
ok "top bar hides; move the mouse to the top edge to show it"
