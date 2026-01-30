{ pkgs, ... }:

{
  # Common configuration for all macOS (Darwin) systems

  # TouchID authentication for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # nix-index for comma
  programs.nix-index-database.comma.enable = true;

  # macOS-specific packages
  environment.systemPackages = with pkgs; [
    hexfiend
    keycastr
    cyberduck
    nixfmt-rfc-style
  ];
}
