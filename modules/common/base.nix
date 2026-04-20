{ pkgs, inputs, ... }:

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
    vault
    # wakatime-cli

    (inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace packages/opencode/script/build.ts \
          --replace-fail 'external: ["node-gyp"]' 'external: ["node-gyp", "prettier", "prettier/plugins/babel", "prettier/plugins/estree"]'
      '';
    }))
  ];
}
