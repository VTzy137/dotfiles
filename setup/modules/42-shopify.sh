# desc: Shopify CLI + theme tools, needs node
# default: off
# check: ls ~/.nvm/versions/node/*/bin/shopify || has shopify
set +u
. "$HOME/.nvm/nvm.sh" 2> /dev/null || true
set -u
has npm || die "npm not found: install the node module first"
npm install -g @shopify/cli@latest
ok "shopify $(shopify version 2> /dev/null)"
