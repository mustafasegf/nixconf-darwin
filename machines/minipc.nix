{
  pkgs,
  lib,
  config,
  ...
}:

{
  # Machine-specific configuration for minipc
  # This is a server machine running k3s, Docker, and cloudflared

  # Import server profile
  imports = [
    ../modules/nixos/server.nix
  ];

  # Build configuration - limit parallel builds to 7 cores
  nix.settings = {
    cores = 7;
    max-jobs = "auto";
  };

  # Hardware configuration
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelParams = [ "processor.max_cstate=1" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0ed1f3c0-c49c-4ff6-bdbe-267bc24a997e";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/c85c9b61-643c-4c2e-addc-bbb937d64e16";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2A6D-642D";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # Networking
  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "minipc";

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU microcode
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.x86.msr.enable = true;

  # Users
  users.users."mustafa" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNEKM6YnhuLcLfy5FkCt+rX1M10vMS00zynI6tsta1s mustafa.segf@gmail.com"
    ];
  };

  users.users."budak" = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNEKM6YnhuLcLfy5FkCt+rX1M10vMS00zynI6tsta1s mustafa.segf@gmail.com"
    ];
  };

  # System version
  system.stateVersion = "24.05";
}
