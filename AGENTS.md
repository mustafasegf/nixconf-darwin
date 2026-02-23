# AGENTS.md — Coding Agent Guidelines for nixconf-darwin

NixOS + nix-darwin personal configuration flake. Manages 4 hosts: `mustafa-pc` (Linux desktop),
`minipc` (Linux server), `Mustafa-Assagaf` (work Mac), `mustafa-mac` (personal Mac).

## Build / Deploy Commands

```bash
# NixOS rebuild (Linux)
sudo nixos-rebuild switch --flake .#mustafa-pc
sudo nixos-rebuild switch --flake .#minipc
sudo nixos-rebuild test --flake .#mustafa-pc   # test without making permanent

# Darwin rebuild (macOS)
darwin-rebuild switch --flake .#Mustafa-Assagaf
darwin-rebuild switch --flake .#mustafa-mac

# Check the flake evaluates correctly (no full build)
nix flake check

# Update all flake inputs
nix flake update --commit-lock-file

# Update a single flake input independently
nix flake update <input-name>        # e.g. nix flake update ghostty
```

There is no CI/CD, Makefile, justfile, or test suite. Validation is done by building/switching.

## Formatter

All `.nix` files use **nixfmt** (RFC-style, not nixfmt-classic). Format before committing:

```bash
nixfmt <file.nix>
nixfmt .       # format everything
```

## Project Layout

```
flake.nix                    # Entry point — all inputs, host definitions, module composition
machines/                    # Per-host hardware configs (match hostname exactly, including case)
modules/common/              # Shared across ALL systems (fonts, nix settings, overlays, packages)
modules/nixos/               # NixOS-only (services, desktop environment, server)
modules/darwin/              # macOS-only (TouchID, homebrew casks, macOS defaults)
home/common/                 # Home-manager shared config (programs, theming, shell)
home/linux/                  # Home-manager Linux-only (picom, autorandr, OBS, rofi)
home/darwin/                 # Home-manager macOS-only
programs/                    # Individual program configs (imported by home/common)
lib/                         # Nix helper functions
config/                      # Raw non-Nix config files (Lua, Python, shell scripts)
secrets/                     # SOPS-encrypted YAML secrets
```

## Module Composition Pattern

Each host in `flake.nix` selects its module layers:
- **All hosts:** `modules/common` (base packages, fonts, nix settings)
- **Desktop hosts:** + `modules/common/desktop.nix` (dev toolchains) + `modules/common/gui.nix` (GUI apps)
- **Linux:** + `modules/nixos/common.nix` + machine-specific (`desktop.nix` or `server.nix`)
- **macOS:** + `modules/darwin/common.nix` + machine-specific (`work.nix` or `personal.nix`)

Home-manager follows the same pattern: `home/common` + `home/linux` or `home/darwin`.

## Code Style

### Module Arguments
```nix
# Always destructure with ellipsis. One arg per line when >2 args.
{ pkgs, lib, inputs, ... }:

# Optional package channels use defaults:
{ pkgs, upkgs ? pkgs, mpkgs ? pkgs, ... }:
```

### Package Lists
```nix
# Use `with pkgs;` for package lists. One package per line.
environment.systemPackages = with pkgs; [
  wget
  fzf
  ripgrep
];

# Use `++` on its own line for conditional appending:
environment.systemPackages =
  with pkgs;
  [
    wget
    fzf
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    linuxPackage
  ];
```

### Attribute Sets
```nix
# Dot notation for single attributes:
services.tailscale.enable = true;

# Brace notation for multiple sub-attributes:
services.pipewire = {
  enable = true;
  alsa.enable = true;
  pulse.enable = true;
};
```

### Platform Conditionals
```nix
# Lists:    lib.optionals pkgs.stdenv.isLinux [ ... ]
# Strings:  lib.optionalString pkgs.stdenv.isDarwin '' ... ''
# Attrsets: // lib.optionalAttrs pkgs.stdenv.isLinux { ... }
# If/else:  if pkgs.stdenv.isLinux then ... else ...
```

### Comments
**Do NOT add comments.** This codebase intentionally avoids comments. The only acceptable
comments are those explaining **why** something non-obvious exists (e.g., overlay workarounds,
why a package is disabled, why `follows` is skipped). Never add:
- Section headers or separators
- Category labels in package lists
- Comments restating what the code does
- Module description comments

### Naming Conventions
- **Files:** lowercase kebab-case (`base.nix`, `gui.nix`). Machine files match hostname exactly (`Mustafa-Assagaf.nix`).
- **Variables:** camelCase (`myUserName`, `platformPaths`). SCREAMING_SNAKE for constants (`RUSTC_VERSION`).
- **Flake inputs:** kebab-case. Vim plugin inputs prefixed `vimPlugins_` (processed by `lib/mkFlake2VimPlugin.nix`).
- **Custom options:** namespaced under `custom.*` (e.g., `custom.enableXcode`).

### Overlays
```nix
# Always use (final: prev: { ... }) — not (self: super: { ... })
# Always include a comment explaining WHY the overlay exists
nixpkgs.overlays = [
  (final: prev: {
    pkg = prev.pkg.overrideAttrs (old: { ... });
  })
];
```

## Adding Flake Inputs

1. Add the input in `flake.nix` under `inputs`.
2. Use `inputs.foo.follows = "nixpkgs"` when safe. Skip `follows` if the upstream pins nixpkgs for compatibility (e.g., ghostty).
3. Access in modules via `inputs.foo.packages.${pkgs.stdenv.hostPlatform.system}.default`.
4. Import NixOS/Darwin/HM modules via `inputs.foo.nixosModules.default` etc. in the host's `imports` list.
5. If the input provides a binary cache, add substituters/keys to `nix.settings` in `modules/common/default.nix`.

## Adding Packages

- **All systems:** `modules/common/base.nix` (CLI tools) or `modules/common/desktop.nix` (dev tools)
- **GUI systems (Linux + macOS):** `modules/common/gui.nix`
- **Linux desktop only:** `modules/nixos/desktop.nix`
- **macOS only (nix packages):** `modules/darwin/common.nix`
- **macOS only (homebrew casks):** `modules/darwin/common.nix` under `homebrew.casks`
- **Home-manager programs:** add config in `programs/`, import from `home/common/default.nix`

When a package supports catppuccin theming, prefer declaring it in home-manager
(`home/common/default.nix`) so the catppuccin module auto-themes it.

## Secrets (SOPS)

- Secrets live in `secrets/*.yaml`, encrypted with age keys derived from SSH keys.
- `.sops.yaml` defines encryption rules. `modules/common/sops.nix` auto-generates the age key.
- Encrypt: `sops secrets/foo.yaml`
- Re-encrypt all: `./re-encrypt-secrets.sh`
- Secrets are decrypted at **runtime** by systemd services, not at build time.

## Commit Messages

Follow conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`
Optional scope: `fix(sudo):`, `refactor(rofi):`
Lowercase after prefix, no period, single line.
