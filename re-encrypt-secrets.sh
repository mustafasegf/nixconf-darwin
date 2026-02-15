#!/usr/bin/env bash
# Script to re-encrypt secrets with your user SSH key
# This adds your user key while keeping the host key

set -euo pipefail

echo "Re-encrypting secrets to include your user SSH key..."
echo "This will allow you to decrypt secrets without root access."
echo ""

# Use the host key to decrypt and your user key to encrypt
sudo SOPS_AGE_KEY_FILE=/etc/ssh/ssh_host_ed25519_key \
  nix-shell -p sops --run "sops updatekeys -y secrets/github-runner.yaml"

echo ""
echo "✓ Secret re-encrypted successfully!"
echo "You can now decrypt secrets using your user key at ~/.config/sops/age/keys.txt"
echo ""
echo "Test decryption with:"
echo "  sops -d secrets/github-runner.yaml"
