{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    systemd-manager-tui
  ];

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
  };

  services.netdata.enable = true;
  services.ucodenix.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "35c192ce9b045898"
      "8850338390eddd9b"
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
