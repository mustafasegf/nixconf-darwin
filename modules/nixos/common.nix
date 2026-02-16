{ pkgs, ... }:

{
  # Common configuration for all NixOS systems

  # Services common to all Linux systems
  services.netdata.enable = true;
  services.ucodenix.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "35c192ce9b045898" # home network
      "8850338390eddd9b" # minecraft
    ];
  };

  # OOM protection for nix builds
  # https://discourse.nixos.org/t/nix-build-ate-my-ram/35752
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeSwapThreshold = 100;
    freeSwapKillThreshold = 100;
  };

  systemd.slices.nix-daemon.sliceConfig = {
    ManagedOOMMemoryPressure = "kill";
    ManagedOOMMemoryPressureLimit = "50%";
  };
  systemd.services.nix-daemon.serviceConfig = {
    Slice = "nix-daemon.slice";
    OOMScoreAdjust = 1000;
  };

  # Systemd services
  systemd.services.ryzen-disable-c6 = {
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
}
