#!/bin/bash

# Determine directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"

# If script is run outside the dotfiles directory
if [ ! -f "$SOURCE_DIR/.zshrc" ]; then
    DOTFILES_REPO="${1:-https://github.com/VTzy137/dotfiles.git}"
    echo "Cloning dotfiles from $DOTFILES_REPO..."
    git clone "$DOTFILES_REPO" "$HOME/dotfiles"
    SOURCE_DIR="$HOME/dotfiles"
fi

sudo apt update
sudo apt install -y vim neovim git

# Copy dotfiles
cp -rf "$SOURCE_DIR/.config/nvim" ~/.config/nvim
cp "$SOURCE_DIR/.vimrc" ~/.vimrc
cp "$SOURCE_DIR/.zshrc" ~/.zshrc
cp "$SOURCE_DIR/.bashrc" ~/.bashrc

mkdir -p ~/.config/Cursor/User
if [ -f "$SOURCE_DIR/cursor/settings.json" ]; then
    cp "$SOURCE_DIR/cursor/settings.json" ~/.config/Cursor/User/settings.json
elif [ -f "$SOURCE_DIR/cursor/setting.json" ]; then
    cp "$SOURCE_DIR/cursor/setting.json" ~/.config/Cursor/User/settings.json
fi

if [ -f "$SOURCE_DIR/cursor/keybindings.json" ]; then
    cp "$SOURCE_DIR/cursor/keybindings.json" ~/.config/Cursor/User/keybindings.json
fi

# Terminal profile setup
if [ ! -d "/tmp/terminal-profile" ]; then
    git clone https://github.com/pixegami/terminal-profile.git /tmp/terminal-profile
fi
cd /tmp/terminal-profile
./install_powerline.sh
./install_terminal.sh
./install_profile.sh

dconf dump /org/gnome/terminal/legacy/profiles:/ > ~/gnome-terminal-profiles.dconf

sudo apt-get install -y neofetch
neofetch --ascii_colors 6 7 --colors 2 2 2 2
