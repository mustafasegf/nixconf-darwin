{ pkgs, ... }:

{
  security.pam.services.sudo_local.touchIdAuth = true;

  programs.nix-index-database.comma.enable = true;

  environment.systemPackages = with pkgs; [
    hexfiend
    keycastr
    cyberduck
    nixfmt
    moonlight-qt
    winbox4
  ];

  homebrew = {
    enable = true;
    casks = [
      "ghostty"
      "wacom-tablet"
    ];
  };
}
