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
        nodejs
        pnpm

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
        prettier
        cmake-format

        pyright
        typescript-language-server
        tflint
        vscode-langservers-extracted
        tailwindcss-language-server
        taplo
        graphql-language-service-cli
        sqls
        svelte-language-server
        astro-language-server
        emmet-ls
        lua-language-server
        bash-language-server
        diagnostic-languageserver
        nixd
        nixfmt
        texlab
        intelephense
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
        sass
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
        (writeShellScriptBin "slack-cli" ''
          exec ${pkgs.slack-cli}/bin/slack "$@"
        '')
      ]
      ++ lib.optionals config.custom.enableXcode [
        xcodes
      ];
  };
}
