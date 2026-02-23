{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hello
    wget
    fzf
    zip
    unzip
    htop
    gnused
    gnugrep
    # atuin - moved to HM for catppuccin theming
    cowsay

    fd
    ripgrep
    jq
    yq-go
    file
    rmw
    colordiff

    man
    man-pages
    man-pages-posix
    iotop

    # lazygit, yazi, eza - moved to HM for catppuccin theming
    mosh
    p7zip
    dust
    hexyl
    w3m
    zellij

    comma
    direnv
    nix-direnv
    nix-index

    python3
    # wakatime-cli
  ];
}
