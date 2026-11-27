# desc: Neovim + lazy.nvim plugins from .config/nvim (also uses .vimrc and vim-plug)
# default: on
# check: has nvim && [ -d ~/.local/share/nvim/lazy/lazy.nvim ]
apt_install neovim xclip wl-clipboard build-essential
# init.lua sources ~/.vimrc, which needs vim-plug
curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
[ -L ~/.config/nvim ] || warn "~/.config/nvim is not linked yet, run the dotfiles module"
nvim --headless +PlugInstall +qa > /dev/null 2>&1 || true
nvim --headless "+Lazy! restore" +qa || warn "lazy.nvim restore had errors, open nvim and run :Lazy"
ok "neovim plugins (versions from lazy-lock.json)"
