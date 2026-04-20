{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    custom.enableXcode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Xcode and related development tools";
    };
  };

  config = {
    environment.systemPackages =
      with pkgs;
      [
        go
        gofumpt
        gopls
        gotools
        delve
        gotestsum
        golangci-lint
        go-tools

        jdk
        jdt-language-server
        maven
        gradle

        bun
        rustup
        nodePackages.nodejs
        nodePackages.npm
        nodePackages.pnpm

        cargo-watch
        cargo-expand
        bacon
        evcxr
        rust-script
        cargo-flamegraph
        cargo-tarpaulin
        cargo-generate
        cargo-zigbuild
        cargo-bootimage
        cargo-mommy

        zig
        deno
        gleam
        erlang
        ghc
        cabal-install
        # dotnet-sdk  # requires Swift build on macOS
        php83
        php83Packages.composer
        swi-prolog
        vlang

        dune_3
        ocaml
        opam
        ocamlPackages.findlib
        ocamlPackages.ocaml-lsp

        terragrunt
        opentofu
        kubectl
        # k9s - moved to HM for catppuccin theming
        kustomize
        kcat
        grpcurl
        teleport
        kubectx
        kubernetes-helm
        google-cloud-sdk

        libiconv
        speedtest-cli
        git-filter-repo
        github-copilot-cli
        air
        cloc
        gdu
        neofetch
        hyfetch
        fastfetch
        uwufetch
        patchelf
        nix-output-monitor
        glow
        gum
        tmate
        mods
        mold
        geckodriver
        go-swag
        autoconf
        subversionClient

        wireguard-tools
        android-tools
        mtr
        scrcpy

        black
        stylua
        shfmt
        nodePackages.prettier
        cmake-format

        pyright
        nodePackages.typescript-language-server
        tflint
        nodePackages.vscode-langservers-extracted
        nodePackages_latest."@tailwindcss/language-server"
        taplo
        nodePackages.graphql-language-service-cli
        sqls
        nodePackages.svelte-language-server
        nodePackages."@astrojs/language-server"
        emmet-ls
        lua-language-server
        nodePackages.bash-language-server
        nodePackages.diagnostic-languageserver
        nixd
        nixfmt
        texlab
        nodePackages.intelephense
        cmake-language-server
        quick-lint-js

        gcc
        # gdb  # build fails on modern macOS with clang
        k6
        semgrep
        tig

        scc
        hexedit
        nasm
        bear
        tree
        cookiecutter
        termshark

        krew
        ossutil
        confluent-platform
        ast-grep
        uv
        pdftk
        moreutils
        prometheus-alertmanager
        prometheus

        protobuf
        grpc-tools
        protoc-gen-go
        protoc-gen-doc
        protoc-gen-rust

        yarn
        nodePackages.sass
        nodePackages.vercel
        dive
        inetutils
        rar
        unrar
        gifsicle

        lf
        rclone
        zerotierone
        pkgconf
        unixtools.procps
        glab
        devenv
        tailscale
        linear-cli
      ]
      ++ lib.optionals config.custom.enableXcode [
        xcodes
      ];
  };
}
