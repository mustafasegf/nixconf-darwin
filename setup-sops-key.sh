#!/usr/bin/env bash
# Script to set up sops with your SSH key
# This converts your SSH key to age format for use with sops

set -euo pipefail

# Auto-detect SSH key if not provided
if [ -n "${1:-}" ]; then
  SSH_KEY="$1"
elif [ -f "$HOME/.ssh/id_ed25519" ]; then
  SSH_KEY="$HOME/.ssh/id_ed25519"
elif [ -f "$HOME/.ssh/id_rsa" ]; then
  SSH_KEY="$HOME/.ssh/id_rsa"
elif [ -f "$HOME/.ssh/id" ]; then
  SSH_KEY="$HOME/.ssh/id"
else
  echo "Error: No SSH key found in ~/.ssh/"
  echo "Looked for: id_ed25519, id_rsa, id"
  echo "Usage: $0 [path/to/ssh/key]"
  exit 1
fi

AGE_KEY_DIR="$HOME/.config/sops/age"
AGE_KEY_FILE="$AGE_KEY_DIR/keys.txt"

echo "Setting up sops with SSH key: $SSH_KEY"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
  echo "Error: SSH key not found at $SSH_KEY"
  echo "Usage: $0 [path/to/ssh/key]"
  exit 1
fi

# Create age key directory
mkdir -p "$AGE_KEY_DIR"

# Convert SSH key to age format
echo "Converting SSH key to age format..."
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i $SSH_KEY" > "$AGE_KEY_FILE"

# Set proper permissions
chmod 600 "$AGE_KEY_FILE"

echo "✓ Age key created at: $AGE_KEY_FILE"
echo ""

# Get the public key
PUBLIC_KEY=$(nix-shell -p ssh-to-age --run "ssh-to-age -i ${SSH_KEY}.pub")
echo "Your age public key is:"
echo "  $PUBLIC_KEY"
echo ""
echo "Add this to .sops.yaml to encrypt secrets for yourself:"
echo "  - &your_name $PUBLIC_KEY"
echo ""
echo "You can now use sops to decrypt secrets that are encrypted for this key!"
