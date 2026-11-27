# desc: zsh + oh-my-zsh, autosuggestions/highlighting, pixegami-agnoster theme, default shell
# default: on
# check: [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ] && [ "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v zsh)" ]
apt_install zsh fonts-powerline dconf-cli
if [ ! -d ~/.oh-my-zsh ]; then
    # KEEP_ZSHRC: don't replace our linked ~/.zshrc; CHSH/RUNZSH: we handle those
    KEEP_ZSHRC=yes CHSH=no RUNZSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
custom=~/.oh-my-zsh/custom
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting"

# Theme and GNOME Terminal colours from pixegami/terminal-profile (only those files; its
# scripts would overwrite ~/.zshrc and ~/.vimrc)
tp="${XDG_CACHE_HOME:-$HOME/.cache}/terminal-profile"
clone_or_pull https://github.com/pixegami/terminal-profile.git "$tp"
cp "$tp/configs/pixegami-agnoster.zsh-theme" "$custom/themes/"
# Roboto Mono for Powerline: the font the terminal profile below uses
mkdir -p ~/.local/share/fonts/RobotoMonoPowerline
cp "$tp"/fonts/RobotoMono/*.ttf ~/.local/share/fonts/RobotoMonoPowerline/
fc-cache -f > /dev/null
if has gnome-terminal; then
    id=fb358fc9-49ea-4252-ad34-1d25c649e633
    dconf load "/org/gnome/terminal/legacy/profiles:/:$id/" < "$tp/configs/terminal_profile.dconf"
    list="$(dconf read /org/gnome/terminal/legacy/profiles:/list || true)"
    if [[ "$list" != *"$id"* ]]; then
        if [ -z "$list" ] || [ "$list" = "@as []" ]; then list="['$id']"; else list="${list%]}, '$id']"; fi
        dconf write /org/gnome/terminal/legacy/profiles:/list "$list"
    fi
    dconf write /org/gnome/terminal/legacy/profiles:/default "'$id'"
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    sudo chsh -s "$(command -v zsh)" "$USER"
    ok "zsh is now your login shell (applies at next login)"
fi
