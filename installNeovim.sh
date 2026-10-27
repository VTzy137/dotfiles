#!/bin/bash

# 1. Define Neovim data directory and vim-plug path
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload"
PLUG_VIM="$DATA_DIR/plug.vim"

# 2. Download vim-plug if it doesn't exist
if [ ! -f "$PLUG_VIM" ]; then
    echo "Installing vim-plug for Neovim..."
    curl -fLo "$PLUG_VIM" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# 3. Ensure init.lua exists (optional: adds basic plug block if missing)
INIT_LUA="$HOME/.config/nvim/init.lua"
mkdir -p "$(dirname "$INIT_LUA")"

if [ ! -f "$INIT_LUA" ]; then
    echo "Creating a basic init.lua..."
    cat <<EOF > "$INIT_LUA"
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
-- Add plugins here, for example:
Plug('tpope/vim-sensible')
Plug('nvim-tree/nvim-tree.lua')
vim.call('plug#end')
EOF
fi

# 4. Run PlugInstall non-interactively
echo "Installing Neovim plugins..."
nvim --headless +PlugInstall +qa

echo "Neovim setup complete!"

sudo apt install wl-clipboard
sudo apt install xclip
