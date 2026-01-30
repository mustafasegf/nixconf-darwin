{ pkgs, ... }:

{
  # GUI packages shared across desktop systems (not for headless servers)
  environment.systemPackages = with pkgs; [
    ## Terminal emulators
    iterm2
    kitty

    ## Development tools
    postman
    dbeaver-bin

    ## Communication
    slack
    discord

    ## Network analysis
    wireshark
  ];
}
