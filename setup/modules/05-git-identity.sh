# desc: Git name + email for commits (saved in ~/.gitconfig.local, not the repo)
# default: on
# check: git config -f ~/.gitconfig.local user.name && git config -f ~/.gitconfig.local user.email
# input: yes
f=~/.gitconfig.local
cur_name="$(git config -f "$f" user.name 2> /dev/null || true)"
cur_email="$(git config -f "$f" user.email 2> /dev/null || true)"
read -rp "git user.name [${cur_name}]: " name
read -rp "git user.email [${cur_email}]: " email
name="${name:-$cur_name}" email="${email:-$cur_email}"
[ -n "$name" ] && [ -n "$email" ] || die "name and email are both needed"
git config -f "$f" user.name "$name"
git config -f "$f" user.email "$email"
ok "git identity: $name <$email>"
