{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    systemd-manager-tui
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  services = {
    netdata.enable = true;
    ucodenix.enable = true;
    zerotierone = {
      enable = true;
      joinNetworks = [
        "35c192ce9b045898"
        "8850338390eddd9b"
      ];
    };
    earlyoom = {
      enable = true;
      enableNotifications = true;
      freeSwapThreshold = 100;
      freeSwapKillThreshold = 100;
    };
  };

  boot.kernelParams = lib.optionals config.hardware.cpu.amd.updateMicrocode [
    "microcode.amd_sha_check=off"
  ];

  # OOM protection for nix builds
  # https://discourse.nixos.org/t/nix-build-ate-my-ram/35752

  systemd = {
    slices.nix-daemon.sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services.nix-daemon.serviceConfig = {
      Slice = "nix-daemon.slice";
      OOMScoreAdjust = 1000;
    };
    services.ryzen-disable-c6 = {
      description = "Ryzen Disable C6";
      wantedBy = [
        "basic.target"
        "suspend.target"
        "hibernate.target"
      ];
      after = [
        "sysinit.target"
        "local-fs.target"
        "suspend.target"
        "hibernate.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [ "${pkgs.zenstates}/bin/zenstates --c6-disable" ];
      };
    };
  };
}
