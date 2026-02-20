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
    # Desktop/development packages - for machines used for interactive development
    # Not needed on headless servers
    environment.systemPackages =
      with pkgs;
      [
        ## Development toolchains
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

        ## Rust ecosystem
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

        ## Additional languages
        zig
        deno
        gleam
        erlang
        ghc
        cabal-install
        # dotnet-sdk  # Disabled on personal Mac - requires Swift build
        php83
        php83Packages.composer
        swi-prolog
        vlang

        ## OCaml ecosystem
        dune_3
        ocaml
        opam
        ocamlPackages.findlib
        ocamlPackages.ocaml-lsp

        ## Cloud and Infrastructure
        terragrunt
        opentofu
        kubectl
        k9s
        kustomize
        kcat
        grpcurl
        teleport
        kubectx
        kubernetes-helm
        google-cloud-sdk

        ## Development utilities
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

        ## Networking and security
        wireguard-tools
        android-tools
        mtr
        scrcpy

        ## Code formatters
        black
        stylua
        shfmt
        nodePackages.prettier
        cmake-format

        ## Language servers
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

        ## Debugging and profiling
        gcc
        # gdb  # Disabled - build fails on modern macOS with clang
        k6
        semgrep
        tig

        ## Analysis tools
        scc
        hexedit
        nasm
        bear
        tree
        cookiecutter
        termshark

        ## DevOps tools
        krew
        ossutil
        confluent-platform
        ast-grep
        uv
        pdftk
        moreutils
        prometheus-alertmanager
        prometheus

        ## Protobuf
        protobuf
        grpc-tools
        protoc-gen-go
        protoc-gen-doc
        protoc-gen-rust

        ## Package managers
        yarn
        nodePackages.sass
        nodePackages.vercel
        dive
        inetutils
        rar
        unrar
        gifsicle

        ## File management
        lf
        rclone
        zerotierone
        pkgconf
        unixtools.procps
        glab
        devenv
        tailscale
      ]
      ++ lib.optionals config.custom.enableXcode [
        xcodes
      ];
  };
}
