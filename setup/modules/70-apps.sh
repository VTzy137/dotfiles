# desc: Desktop apps from packages/snap.txt (Discord...)
# default: on
# check: while read -r a _; do snap list "$a" || exit 1; done < <(read_list "$DOTFILES/packages/snap.txt")
has snap || apt_install snapd
while read -r app flags; do
    snap list "$app" > /dev/null 2>&1 && continue
    # shellcheck disable=SC2086
    sudo snap install "$app" $flags || warn "snap: could not install $app"
done < <(read_list "$DOTFILES/packages/snap.txt")
ok "snap apps"
