{
  config,
  pkgs,
  ...
}:

{
  security.pam.services.sudo_local.touchIdAuth = true;

  programs.nix-index-database.comma.enable = true;
  nix.enable = false;

  # Determinate manages nix here (nix.enable = false), so nix.settings is ignored; pass the caches through nix.custom.conf
  environment.etc."nix/nix.custom.conf".text = ''
    extra-trusted-users = mustafa
    extra-substituters = ${toString config.nix.settings.substituters}
    extra-trusted-public-keys = ${toString config.nix.settings.trusted-public-keys}
    connect-timeout = ${toString config.nix.settings.connect-timeout}
  '';

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
    taps = [
      "dimentium/autoraise"
    ];
    casks = [
      "ghostty"
      "wacom-tablet"
      "mullvad-vpn"
      "vlc"
      "mpv"
      "bitwarden"
      "openvpn-connect"
      "scroll-reverser"
      "krisp"
      "discord"
      "notion"
      "orbstack"
      "obs"
      "openmtp"
      "dimentium/autoraise/autoraiseapp"
    ];
  };
}
