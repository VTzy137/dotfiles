# desc: OpenAI Codex CLI (codex), needs node
# default: on
# check: ls ~/.nvm/versions/node/*/bin/codex || has codex
set +u
. "$HOME/.nvm/nvm.sh" 2> /dev/null || true
set -u
has npm || die "npm not found: install the node module first (./install.sh node codex)"
npm install -g @openai/codex@latest
ok "codex $(codex --version 2> /dev/null) (run 'codex' to sign in)"
