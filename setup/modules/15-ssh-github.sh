# desc: SSH key for GitHub: shows the key, waits while you add it on github.com, tests it
# default: on
# check: [ -f ~/.ssh/id_ed25519 ] && git -C "$DOTFILES" remote get-url origin | grep -q "^git@"
# input: yes
KEY=~/.ssh/id_ed25519
mkdir -p ~/.ssh && chmod 700 ~/.ssh
if [ -f "$KEY" ]; then
    ok "using existing key $KEY"
else
    ssh-keygen -q -t ed25519 -C "$USER@$(hostname)" -f "$KEY" -N ""
    ok "created $KEY"
fi

if ! grep -qs '^Host github.com' ~/.ssh/config; then
    printf 'Host github.com\n  HostName github.com\n  User git\n  IdentityFile %s\n  IdentitiesOnly yes\n  AddKeysToAgent yes\n' \
        "$KEY" >> ~/.ssh/config
    chmod 600 ~/.ssh/config
    ok "added github.com to ~/.ssh/config"
fi

# ssh -T always exits 1 on GitHub, even when the key works: check the greeting text instead
# (capturing first, so pipefail doesn't turn that exit 1 into a failed check)
gh_ok() {
    local out
    out="$(ssh -T -o StrictHostKeyChecking=accept-new -o BatchMode=yes -o ConnectTimeout=10 git@github.com 2>&1 || true)"
    grep -q 'successfully authenticated' <<< "$out"
}

if gh_ok; then
    ok "GitHub already accepts this key"
else
    echo
    echo "1. Open https://github.com/settings/ssh/new"
    echo "2. Title: $(hostname)   Key type: Authentication Key"
    echo "3. Paste this whole line as the key:"
    echo
    cat "$KEY.pub"
    echo
    until gh_ok; do
        read -rp "Press Enter once it's added (s = skip for now): " ans
        [ "$ans" = s ] && { warn "skipped; rerun later: ./install.sh ssh-github"; exit 0; }
        gh_ok || warn "GitHub doesn't accept the key yet"
    done
    ok "GitHub accepts the key"
fi

# Now that SSH works, push this repo over SSH
url="$(git -C "$DOTFILES" remote get-url origin 2> /dev/null || true)"
if [[ "$url" == https://github.com/* ]]; then
    git -C "$DOTFILES" remote set-url origin "git@github.com:${url#https://github.com/}"
    ok "dotfiles remote now uses SSH"
fi
