# desc: Claude Code CLI (claude), native installer, updates itself
# default: on
# check: [ -x ~/.local/bin/claude ] || has claude
if [ -x ~/.local/bin/claude ] || has claude; then
    ok "claude already installed ($(~/.local/bin/claude --version 2> /dev/null || claude --version))"
else
    curl -fsSL https://claude.ai/install.sh | bash
    ok "claude installed (run 'claude' to sign in)"
fi
