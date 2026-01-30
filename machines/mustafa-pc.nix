{ pkgs, ... }:

{
  # Machine-specific configuration for mustafa-pc
  # This is a desktop/workstation Linux machine

  # Hardware configuration
  boot.loader.grub.device = "nodev";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
  };

  # User configuration
  users.users."mustafa" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  # System version
  system.stateVersion = "24.05";
}
