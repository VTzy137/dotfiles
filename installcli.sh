#!/bin/bash

# 1. Install NVM (Node Version Manager)
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM into the current shell session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 2. Install Node.js (LTS version) and NPM
echo "Installing Node.js LTS..."
nvm install --lts
nvm use --lts

# 3. Install Yarn globally via Corepack (the modern way)
echo "Installing Yarn..."
corepack enable
corepack prepare yarn@stable --activate

# 4. Install Shopify CLI
echo "Installing Shopify CLI..."
yarn global add @shopify/cli @shopify/theme

# 5. Verification
echo "---------------------------------------"
echo "Installation Complete! Versions:"
node -v
npm -v
yarn -v
shopify version
echo "---------------------------------------"
echo "NOTE: Restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to use nvm immediately."

gsettings set org.gnome.desktop.interface enable-animations false

npm install -g @shopify/cli

sudo apt install build-essential libx11-dev libxtst-dev
