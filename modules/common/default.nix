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

  # Services
  services.tailscale.enable = true;
}
