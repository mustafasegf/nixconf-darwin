{ pkgs, ... }:

{
  nix.settings = {
    cores = 9;
    max-jobs = "auto";
  };

  custom.enableXcode = false;

  # PAM reattach needed for tmux/sudo integration
  security.pam.services.sudo_local.reattach = true;

  nix.enable = false;

  environment.systemPackages = with pkgs; [
    go
    pear-desktop
  ];
}
