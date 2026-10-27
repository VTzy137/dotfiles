#!/bin/bash

# 1. Download vim-plug if it doesn't exist
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    echo "Installing vim-plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# 2. Create/Append to .vimrc
# This uses a 'EOF' block to write the configuration
cat <<EOF > ~/.vimrc
call plug#begin('~/.vim/plugged')

" Add your plugins here
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'

call plug#end()
EOF

# 3. Run PlugInstall automatically and exit
echo "Installing plugins..."
vim +PlugInstall +qall

echo "Vim plugins installed successfully!"

sudo apt install vim-gtk3
