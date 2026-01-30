{ pkgs, ... }:

{
  # Personal Mac profile (for personal machines)
  # Used by machines like mustafa-mac

  # PAM reattach for tmux/sudo integration
  security.pam.services.sudo_local.reattach = true;

  # Disable nix daemon (if needed for personal setup)
  nix.enable = false;

  # Personal-specific packages
  environment.systemPackages = with pkgs; [
    go
    pear-desktop
  ];
}
