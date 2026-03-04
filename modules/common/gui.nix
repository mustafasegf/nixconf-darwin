{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    iterm2
    kitty
    postman
    dbeaver-bin
    slack
    discord
    wireshark
    handy
    ghostty-bin
  ];
}
