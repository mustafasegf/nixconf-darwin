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
  imports = [
    ../modules/nixos/desktop.nix
  ];

  nix.settings.cores = 2;

  custom.enableXcode = false;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
    ];
    initrd.kernelModules = [
      "amdgpu"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];
    kernelModules = [
      "kvm-amd"
      "i2c-dev"
      "i2c-piix4"
      "hid-playstasion"
      "v4l2loopback"
      "k10temp"
      "msr"
    ];
    kernelParams = [
      "amd_iommu=on"
      "processor.max_cstate=1"
    ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "reiserfs"
      "vfat"
      "f2fs"
      "ntfs"
      "cifs"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        useOSProber = true;
        efiSupport = true;
        minegrub-theme = {
          enable = true;
          splash = "100% Flakes!";
          background = "background_options/1.8  - [Classic Minecraft].png";
          boot-options-count = 4;
        };
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1877725c-b780-4b31-8304-0c8a17ac975b";
      fsType = "ext4";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/1725d93d-59b7-4795-a27e-678706b0adf4";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C51D-9D51";
      fsType = "vfat";
    };
    "/win" = {
      device = "/dev/disk/by-uuid/92BEF8A5BEF88351";
      fsType = "ntfs-3g";
      options = [
        "rw"
        "uid=1000"
      ];
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      # upkgs for latest Mesa (better AMD GPU support)
      package = upkgs.mesa;
      package32 = upkgs.pkgsi686Linux.mesa;
      extraPackages = [
        upkgs.mesa.opencl
      ];
    };
  };

  programs.librepods.enable = true;

  systemd.services.bluetooth-rfkill-unblock = {
    description = "Unblock Bluetooth soft-kill";
    wantedBy = [ "bluetooth.service" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
      RemainAfterExit = true;
    };
  };

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "mustafa-pc";
    networkmanager.enable = true;
    firewall.enable = false;
    interfaces.enp113s0.wakeOnLan.enable = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users.mustafa = {
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
        "librepods"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNEKM6YnhuLcLfy5FkCt+rX1M10vMS00zynI6tsta1s mustafa.segf@gmail.com"
      ];
    };
    users.guest = {
      isNormalUser = true;
      description = "Guest account";
      extraGroups = [
        "networkmanager"
        "docker"
      ];
      openssh.authorizedKeys.keys = [ ];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "beekeeper-studio-5.5.3"
    "ventoy-1.1.12"
    "openssl-1.1.1w"
  ];

  system.stateVersion = "22.11";
}
