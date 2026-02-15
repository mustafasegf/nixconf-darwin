# Sops Setup with SSH Keys

Your NixOS configuration is now set up to use sops for secret management with your SSH key **automatically across all your machines**.

## 🚀 Automatic Setup

The configuration automatically:
- Detects your SSH key (`~/.ssh/id_ed25519`, `~/.ssh/id_rsa`, or `~/.ssh/id`)
- Converts it to age format for sops
- Creates `~/.config/sops/age/keys.txt` on every machine
- Sets the `SOPS_AGE_KEY_FILE` environment variable

**This happens automatically when you apply your home-manager configuration!**

## Quick Start

1. **Apply your configuration** (this sets up the age key automatically):
   ```bash
   nix run .#activate
   ```

2. **Re-encrypt existing secrets** to include your user key:
   ```bash
   ./re-encrypt-secrets.sh
   ```
   This requires sudo to access the host key for decryption.

### Manual Setup (Optional)

If you need to manually generate the age key:
```bash
./setup-sops-key.sh
```

## Configuration

- **Age key location**: `~/.config/sops/age/keys.txt`
- **Sops config**: `.sops.yaml` (defines which keys can encrypt/decrypt)
- **Your age public key**: `age1lfhm9yth5recdtjrndrf266t3e5ejhprmdn9ssf7nhcxy4d77cjq3px0a6`

## How It Works

1. **Automatic conversion**: On every machine, your SSH key is automatically converted to age format during home-manager activation
2. **Same key everywhere**: Since you use the same SSH key on all machines, you'll have the same age key everywhere
3. **Seamless decryption**: Sops uses this age key to encrypt/decrypt secrets across all your machines
4. **Fallback support**: The systemd service tries your user key first, then falls back to the host key
5. **Multi-key secrets**: Both keys can decrypt the same secrets (once re-encrypted)

This means you can edit secrets on any machine where you have your SSH key!

## Managing Secrets

### View/Edit a secret:
```bash
sops secrets/github-runner.yaml
```

### Create a new secret:
```bash
sops secrets/new-secret.yaml
```
The `.sops.yaml` file automatically configures encryption for files matching `secrets/*.yaml`

### Encrypt a file for multiple recipients:
The `.sops.yaml` is already configured to encrypt for both:
- `minipc` (host key): `age1k9kqxkxytqxhpcfhhqfkq0p4p8m6lschurs862jzj6futfqukpqsepaep9`
- `mustafa` (your key): `age1lfhm9yth5recdtjrndrf266t3e5ejhprmdn9ssf7nhcxy4d77cjq3px0a6`

## Troubleshooting

### "Failed to get the data key" error:
- Run `./re-encrypt-secrets.sh` to add your key to existing secrets
- Make sure `~/.config/sops/age/keys.txt` exists

### Permission denied on host key:
- The systemd service will automatically fall back to your user key
- After running `./re-encrypt-secrets.sh`, you won't need the host key anymore

## Files Modified

- `.sops.yaml` - Added your user key as a recipient
- `modules/nixos/server.nix` - Updated systemd service to use your key
- `~/.config/sops/age/keys.txt` - Your private age key (keep this safe!)
