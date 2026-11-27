# Helpers shared by every setup module. Sourced by install.sh, not run directly.
# DOTFILES is the repo root; modules use it to find their files.

c_blue=$'\e[1;34m' c_green=$'\e[1;32m' c_yellow=$'\e[1;33m' c_red=$'\e[1;31m' c_off=$'\e[0m'
info() { printf '%s==>%s %s\n' "$c_blue" "$c_off" "$*"; }
ok() { printf '%s ok%s %s\n' "$c_green" "$c_off" "$*"; }
warn() { printf '%s !!%s %s\n' "$c_yellow" "$c_off" "$*" >&2; }
die() {
    printf '%sERR%s %s\n' "$c_red" "$c_off" "$*" >&2
    exit 1
}
has() { command -v "$1" > /dev/null 2>&1; }

# apt update at most once per run
_APT_UPDATED=
apt_update() {
    [ -n "$_APT_UPDATED" ] && return
    sudo apt-get update -q
    _APT_UPDATED=1
}

# Install only the packages that are missing; a package apt doesn't know is skipped with a warning
apt_install() {
    local missing=() p
    for p in "$@"; do
        dpkg -s "$p" > /dev/null 2>&1 || missing+=("$p")
    done
    [ ${#missing[@]} -eq 0 ] && return
    apt_update
    if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"; then
        for p in "${missing[@]}"; do
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$p" || warn "apt: could not install $p"
        done
    fi
}

# Read a package list: one name per line, # comments and blank lines ignored
read_list() { sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$1" | grep -v '^$'; }

# Symlink a repo file into place. An existing different file is moved to <dest>.bak.<time> first,
# so nothing is lost and editing the live file edits the repo.
link() {
    local src="$DOTFILES/$1" dest="$2"
    [ -e "$src" ] || die "link: $src does not exist"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        return
    fi
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        local bak
        bak="$dest.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$dest" "$bak"
        warn "moved old $dest to $bak"
    fi
    ln -s "$src" "$dest"
    ok "linked $dest"
}

# Clone a repo, or fast-forward it if it is already there
clone_or_pull() {
    local url=$1 dir=$2
    if [ -d "$dir/.git" ]; then
        git -C "$dir" pull -q --ff-only || warn "could not update $dir"
    else
        git clone -q --depth 1 "$url" "$dir"
    fi
}

# Install + enable a GNOME Shell extension from extensions.gnome.org for this GNOME version
gnome_ext_install() {
    local uuid=$1 shell path tmp
    if ! gnome-extensions info "$uuid" > /dev/null 2>&1; then
        shell="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
        path="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell" |
            python3 -c 'import json,sys; print(json.load(sys.stdin)["download_url"])')" ||
            die "$uuid has no release for GNOME $shell yet"
        tmp="$(mktemp -d)"
        curl -fsSL -o "$tmp/ext.zip" "https://extensions.gnome.org$path"
        gnome-extensions install --force "$tmp/ext.zip"
        rm -rf "$tmp"
        ok "installed $uuid"
    fi
    gnome_ext_enable "$uuid"
}

# Turn on an installed (or just copied/linked) extension. GNOME only finds new extensions
# after a log out, so fall back to adding it to the enabled list for next login.
gnome_ext_enable() {
    local uuid=$1
    gnome-extensions enable "$uuid" 2> /dev/null ||
        gsettings set org.gnome.shell enabled-extensions "$(python3 -c '
import ast, sys
l = ast.literal_eval(sys.argv[1].replace("@as ", ""))
print(l if sys.argv[2] in l else l + [sys.argv[2]])' "$(gsettings get org.gnome.shell enabled-extensions)" "$uuid")"
    if gnome-extensions info "$uuid" 2> /dev/null | grep -q 'State: ACTIVE'; then
        ok "$uuid is on"
    else
        warn "$uuid is enabled; log out and back in for GNOME to load it"
    fi
}

# Set a key in an extension's settings (its schema ships inside the extension)
ext_gset() {
    local uuid=$1
    shift
    gsettings --schemadir "$HOME/.local/share/gnome-shell/extensions/$uuid/schemas" set "$@"
}
