# desc: Vietnamese typing with ibus-unikey
# default: on
# check: dpkg -s ibus-unikey
apt_install ibus ibus-unikey
ibus restart > /dev/null 2>&1 || true
# Add Unikey to GNOME's input sources if it isn't there
if has gsettings; then
    src="$(gsettings get org.gnome.desktop.input-sources sources)"
    if [[ "$src" != *unikey* ]]; then
        gsettings set org.gnome.desktop.input-sources sources "${src%]}, ('ibus', 'Unikey')]"
        ok "Unikey added to input sources (Super+Space switches)"
    fi
fi
