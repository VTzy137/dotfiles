# desc: tmux: every terminal window opens in tmux (.zshrc), vim keys, mouse, splits in current folder
# default: on
# check: has tmux && [ "$(readlink ~/.tmux.conf)" = "$DOTFILES/.tmux.conf" ]
apt_install tmux
link .tmux.conf ~/.tmux.conf
# reload running tmux servers so changes show up right away
tmux source-file ~/.tmux.conf 2> /dev/null || true
ok "tmux: new terminals open in tmux (zsh); Ctrl+B | or - to split, Alt+h/j/k/l to move, Ctrl+B b status bar"
