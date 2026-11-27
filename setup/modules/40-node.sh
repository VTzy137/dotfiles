# desc: nvm + Node.js LTS + yarn/pnpm via corepack
# default: on
# check: [ -s ~/.nvm/nvm.sh ] && ls ~/.nvm/versions/node/*/bin/node
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    # PROFILE=/dev/null: .zshrc/.bashrc already load nvm
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash
fi
set +u
. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'
corepack enable
set -u
ok "node $(node -v), npm $(npm -v)"
