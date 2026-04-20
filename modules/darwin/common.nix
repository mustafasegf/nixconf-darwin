{ pkgs, ... }:

{
  security.pam.services.sudo_local.touchIdAuth = true;

  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    awscli2
    hexfiend
    keycastr
    cyberduck
    nixfmt
    moonlight-qt
    winbox4
    nh
  ];

  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "wacom-tablet"
      "mullvad-vpn"
      "vlc"
      "mpv"
    ];
  };
}
