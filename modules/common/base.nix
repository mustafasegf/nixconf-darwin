{ pkgs, ... }:

{
  # Minimal base packages - truly common across ALL systems (servers + desktops)
  # Only essential command-line tools that every system needs
  environment.systemPackages = with pkgs; [
    ## Core utilities
    hello
    wget
    fzf
    fzf-zsh
    zip
    unzip
    htop
    gnused
    atuin
    cowsay

    ## File and text processing
    fd
    ripgrep
    jq
    yq-go

    ## System monitoring
    man
    man-pages
    man-pages-posix

    ## Terminal tools
    lazygit
    mosh
    p7zip

    ## Nix ecosystem
    comma
    direnv
    nix-direnv
    nix-index
  ];
}
