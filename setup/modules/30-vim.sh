# desc: Vim (gtk3, clipboard) + powerline + vim-plug plugins from .vimrc
# default: on
# check: dpkg -s vim-gtk3 && [ -d ~/.vim/plugged ]
apt_install vim-gtk3 powerline xclip wl-clipboard
curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
[ -L ~/.vimrc ] || warn "~/.vimrc is not linked yet, run the dotfiles module"
vim -Es -u ~/.vimrc +PlugInstall +qall < /dev/null || true
ok "vim plugins"
