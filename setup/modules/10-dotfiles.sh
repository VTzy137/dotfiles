# desc: Symlink shell/git/vim/nvim configs into ~ (old files kept as .bak)
# default: on
# check: for f in .bashrc .zshrc .vimrc .gitconfig .lessfilter .prettierrc .config/nvim; do [ "$(readlink ~/$f)" = "$DOTFILES/$f" ] || exit 1; done
link .bashrc ~/.bashrc
link .zshrc ~/.zshrc
link .vimrc ~/.vimrc
link .gitconfig ~/.gitconfig
link .lessfilter ~/.lessfilter
link .prettierrc ~/.prettierrc
link .config/nvim ~/.config/nvim

# Git name/email are set by the git-identity module, in ~/.gitconfig.local

# Add the repo's cron lines that aren't in the crontab yet
current="$(crontab -l 2> /dev/null || true)"
new="$current"
while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -qxF -- "$line" <<< "$current" || new+=$'\n'"$line"
done < "$DOTFILES/crontab"
if [ "$new" != "$current" ]; then
    printf '%s\n' "$new" | sed '/^$/d' | crontab -
    ok "crontab updated"
fi
