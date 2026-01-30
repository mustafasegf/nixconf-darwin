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
