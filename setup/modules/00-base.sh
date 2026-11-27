# desc: Core CLI tools (git, curl, ripgrep, fzf, bat, delta...) from packages/apt.txt
# default: on
# check: mapfile -t p < <(read_list "$DOTFILES/packages/apt.txt"); dpkg -s "${p[@]}"
mapfile -t pkgs < <(read_list "$DOTFILES/packages/apt.txt")
apt_install "${pkgs[@]}"

# Ubuntu renames these two; give them their usual names
mkdir -p ~/.local/bin
has fdfind && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
has batcat && ln -sf "$(command -v batcat)" ~/.local/bin/bat
git lfs install --skip-repo > /dev/null
ok "base packages"
