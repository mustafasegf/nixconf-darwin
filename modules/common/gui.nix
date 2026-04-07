{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  environment.systemPackages =
    with pkgs;
    [
      iterm2
      kitty
      postman
      dbeaver-bin
      slack
      discord
      wireshark
      qbittorrent
      handy
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
