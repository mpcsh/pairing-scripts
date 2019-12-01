#!/usr/bin/env bash
set -euo pipefail

echo "ssh key:"
read -r SSH_KEY

mkdir ~/.ssh
echo "$SSH_KEY" > ~/.ssh/authorized_keys
chmod -R go-rwx ~/.ssh

ln -sf /shared/git-authors ~/.git-authors

make -C /shared/dotfiles
