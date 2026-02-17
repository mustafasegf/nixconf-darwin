{
  config,
  lib,
  pkgs,
  upkgs ? pkgs,
  ppkgs ? pkgs,
  staging-pkgs ? pkgs,
  mpkgs ? pkgs,
  ...
}:

{
  # Machine-specific configuration for mustafa-pc
  # Desktop Linux workstation with AMD CPU/GPU, Qtile WM
  # Multiple package sets available: pkgs, upkgs, ppkgs, staging-pkgs, mpkgs

  imports = [
    ../modules/nixos/desktop.nix
  ];

  nix.settings.cores = 14;

  # xcodes is macOS-only (manages Xcode installations)
  custom.enableXcode = false;

  # ========================================
  # BOOT & KERNEL
  # ========================================

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
  ];
  boot.initrd.kernelModules = [
    "amdgpu"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
  ];
  boot.kernelModules = [
    "kvm-amd"
    "i2c-dev"
    "i2c-piix4"
    "hid-playstasion"
    "v4l2loopback"
    "k10temp"
    "msr"
  ];
  boot.kernelParams = [
    "amd_iommu=on"
    "processor.max_cstate=1"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];

  boot.supportedFilesystems = lib.mkForce [
    "btrfs"
    "reiserfs"
    "vfat"
    "f2fs"
    "ntfs"
    "cifs"
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;

  # ========================================
  # FILESYSTEMS
  # ========================================

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1877725c-b780-4b31-8304-0c8a17ac975b";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/1725d93d-59b7-4795-a27e-678706b0adf4";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C51D-9D51";
    fsType = "vfat";
  };

  fileSystems."/win" = {
    device = "/dev/disk/by-uuid/92BEF8A5BEF88351";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  # ========================================
  # HARDWARE
  # ========================================

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # Use upkgs for latest Mesa (better AMD GPU support)
    package = upkgs.mesa;
    package32 = upkgs.pkgsi686Linux.mesa;
    extraPackages = [
      upkgs.mesa.opencl
    ];
  };

  # ========================================
  # NETWORKING
  # ========================================

  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "mustafa-pc";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;
  networking.interfaces.enp10s0.wakeOnLan.enable = true;

  # ========================================
  # USERS
  # ========================================

  users.defaultUserShell = pkgs.zsh;

  users.users.mustafa = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "rtkit"
      "media"
      "audio"
      "sys"
      "wireshark"
      "rfkill"
      "video"
      "uucp"
      "docker"
      "vboxusers"
      "libvirtd"
      "render"
      "adbusers"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNEKM6YnhuLcLfy5FkCt+rX1M10vMS00zynI6tsta1s mustafa.segf@gmail.com"
    ];
  };

  # ========================================
  # SYSTEM
  # ========================================

  system.stateVersion = "22.11";
}
