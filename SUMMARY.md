# Configuration Changes Summary

## ✅ Changes Completed

### 1. Shell Alias
- Added `oc` as an alias for `opencode` in `programs/zsh.nix`
- Works across all your machines

### 2. Fixed Package Removal
- Removed deprecated `fzf-zsh` package from `modules/common/base.nix`
- fzf now uses built-in zsh integration

### 3. Sops Secret Management Setup

#### Automatic Setup Across All Machines
Created `modules/common/sops.nix` that automatically:
- Detects your SSH key on every machine (`id_ed25519`, `id_rsa`, or `id`)
- Converts it to age format for sops
- Creates `~/.config/sops/age/keys.txt`
- Sets `SOPS_AGE_KEY_FILE` environment variable

**This means:** Since you use the same SSH key on all machines, sops will work automatically everywhere!

#### Updated Configurations
- **`.sops.yaml`**: Added your user key as a default recipient
  - Your key: `age1lfhm9yth5recdtjrndrf266t3e5ejhprmdn9ssf7nhcxy4d77cjq3px0a6`
  - Host key: `age1k9kqxkxytqxhpcfhhqfkq0p4p8m6lschurs862jzj6futfqukpqsepaep9`

- **`modules/nixos/server.nix`**: Updated GitHub runner secret handling
  - Uses systemd service to decrypt and apply secrets
  - Prefers user key over host key
  - No longer uses sops-nix (which doesn't support full encrypted YAML files)

#### Helper Scripts Created
1. **`setup-sops-key.sh`**: Manually convert SSH key to age (not needed, but useful)
2. **`re-encrypt-secrets.sh`**: Re-encrypt existing secrets to include your user key
3. **`SOPS_SETUP.md`**: Complete documentation

## 📋 Next Steps

### Required:
1. Apply the configuration:
   ```bash
   nix run .#activate
   # Enter sudo password when prompted
   ```

### Recommended:
2. Re-encrypt the GitHub runner secret to include your user key:
   ```bash
   ./re-encrypt-secrets.sh
   # Enter sudo password when prompted
   ```

After re-encrypting, you can edit secrets on any machine with:
```bash
sops secrets/github-runner.yaml
```

## 🔑 How Multi-Machine Sops Works

1. **Same SSH key** on all machines → **Same age key** on all machines
2. Secrets encrypted for your age key can be decrypted on **any** machine
3. Home-manager automatically sets up the age key during activation
4. No manual configuration needed on new machines!

## Files Modified

- ✅ `programs/zsh.nix` - Added `oc` alias
- ✅ `modules/common/base.nix` - Removed `fzf-zsh`
- ✅ `.sops.yaml` - Added your user key
- ✅ `modules/common/sops.nix` - NEW: Automatic sops setup
- ✅ `home/common/default.nix` - Import sops module
- ✅ `modules/nixos/server.nix` - Updated secret decryption
- ✅ Helper scripts and documentation created

## What Happens on Each Machine

When you apply this configuration on any machine:

1. Home-manager detects your SSH key
2. Converts it to age format
3. Saves to `~/.config/sops/age/keys.txt`
4. Sets environment variables
5. You can now decrypt any secret encrypted for your key!

**Zero manual setup required!** 🚀
