#!/bin/bash
sudo apt install git 

# 1. Define variables (from argument, git config, or interactive prompt)
EMAIL="${1:-$(git config user.email)}"
if [ -z "$EMAIL" ]; then
    read -p "Enter your email for SSH key: " EMAIL
fi
KEY_PATH="$HOME/.ssh/id_ed25519"

# 2. Check if key already exists
if [ -f "$KEY_PATH" ]; then
    echo "SSH key already exists at $KEY_PATH"
else
    echo "Generating new SSH key..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
fi

# 3. Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add "$KEY_PATH"

# 4. Display the public key to be copied
echo "-------------------------------------------------------"
echo "Copy the text below and add it to your GitHub settings:"
echo "-------------------------------------------------------"
cat "${KEY_PATH}.pub"
echo "-------------------------------------------------------"
echo "Open: https://github.com/settings/ssh/new"

echo "To verify your SSH connection, run: ssh -T git@github.com"
