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
      obsidian
      postman
      dbeaver-bin
      slack
      wireshark
      qbittorrent
      (pkgs.ghidra.withExtensions (p: [
        p.ghidra-golanganalyzerextension
        pkgs.ghidra-mcp
      ]))
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      handy
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
      vlc
      mpv
      discord
    ];
}
