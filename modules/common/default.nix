{ pkgs, lib, ... }:

{
  # Base configuration shared across ALL systems (NixOS and macOS)

  imports = [
    ./packages.nix
  ];

  # Environment variables
  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    MANPAGER = "nvim +Man!";
  };

  # Fonts
  fonts.packages =
    with pkgs;
    [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      ibm-plex
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  # Nix configuration
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "mustafa.assagaf"
      "mustafa"
    ];
    fallback = true;
  };

  # Programs
  programs.zsh.enable = true;

  # Nixpkgs config
  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
    allowBroken = true;
  };

  # Overlays
  nixpkgs.overlays = [
    (final: prev: {
      # Use jdrouhard's patched mosh fork with many fixes:
      # - OSC 52 clipboard support for tmux (PR #1104)
      # - SSH agent forwarding (PR #1297)
      # - Undercurl/underline color support
      # - Unicode 16 width tables
      # - Dim and strikethrough support (PR #1059)
      # https://github.com/jdrouhard/mosh/tree/patched
      mosh = prev.mosh.overrideAttrs (old: rec {
        version = "1.4.0-patched-2025-08-24";
        src = prev.fetchFromGitHub {
          owner = "jdrouhard";
          repo = "mosh";
          rev = "3d613c845cae0b8966a5d5dbadf2639a9e2f6fd8";
          hash = "sha256-I0YlND+B7MigFKQg+nnTFQb/li+D5oe/CFwoAc9eODg=";
        };
        # Keep only Nix-specific patches, drop version-specific ones
        patches = builtins.filter (
          p:
          let
            name = builtins.baseNameOf (builtins.toString p);
          in
          builtins.elem name [
            "ssh_path.patch"
            "mosh-client_path.patch"
            "bash_completion_datadir.patch"
          ]
        ) (old.patches or [ ]);
      });
    })
  ];

  # Services
  services.tailscale.enable = true;
}
