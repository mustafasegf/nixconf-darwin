{ pkgs, ... }:

{
  # Common packages shared across all systems (NixOS and macOS)
  environment.systemPackages = with pkgs; [
    hello
    terragrunt
    opentofu
    wireguard-tools
    krew
    ossutil
    confluent-platform
    ast-grep
    k9s
    kustomize
    uv
    pdftk
    moreutils
    android-tools
    mtr
    prometheus-alertmanager
    prometheus

    ## Go toolchain
    go
    gofumpt
    gopls
    gotools
    delve
    gotestsum
    golangci-lint
    go-tools

    ## Java toolchain
    jdk
    jdt-language-server
    maven
    gradle

    ## Terminal and utilities
    iterm2
    kitty
    wget
    fzf
    fzf-zsh

    ## Nix ecosystem
    comma
    direnv
    nix-direnv
    nix-index
    devenv

    ## Basic utilities
    zip
    unzip
    htop
    gnused
    lf
    atuin
    neofetch
    lazygit
    cowsay
    gh-copilot
    air
    cloc
    fd
    gdu
    ripgrep
    hyfetch
    fastfetch
    uwufetch

    ## Core tools
    man
    man-pages
    man-pages-posix
    jq
    yq-go
    libiconv
    postman
    speedtest-cli
    xcodes
    git-filter-repo

    ## Kubernetes and cloud
    kubectl
    kcat
    grpcurl
    teleport
    unixtools.procps
    pkgconf
    kubectx
    kubernetes-helm

    ## Network
    mosh
    glab
    google-cloud-sdk
    p7zip
    scrcpy

    ## Development runtimes
    bun
    rustup
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    # poetry  # Temporarily disabled due to nixpkgs unstable build issue

    ## Communication
    slack
    discord

    ## Code formatters
    black
    stylua
    shfmt

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
    nixd

    ## Databases and storage
    tailscale
    dbeaver-bin
    rclone

    ## Debugging and profiling
    gcc
    gdb
    k6
    semgrep
    tig

    ## Analysis tools
    scc
    hexedit
    nasm
    bear
    zerotierone
    tree
    cookiecutter

    ## Protobuf
    protobuf
    grpc-tools
    protoc-gen-go
    protoc-gen-doc

    ## Network analysis
    termshark
    wireshark

    ## Package managers
    yarn
    dive
    inetutils
    rar
    unrar
    gifsicle

    # (let
    #   packagePypi = name: ver: ref: deps:
    #     python311.pkgs.buildPythonPackage rec {
    #       pname = name;
    #       version = ver;
    #
    #       src = python311.pkgs.fetchPypi {
    #         inherit pname version;
    #         hash = ref;
    #       };
    #
    #       buildInputs = deps;
    #       doCheck = false;
    #     };
    # in python311.withPackages (ps: [
    #   # sha from nix store prefetch-file
    #   (packagePypi "iwlib" "1.7.0"
    #     "sha256-qAX2WXpw7jABq6jwOft7Lct13BXE54UvVZT9Y3kZbaE=" [
    #       wirelesstools
    #       ps.setuptools
    #       ps.cffi
    #     ])
    #   (packagePypi "Appium-Python-Client" "4.0.0"
    #     "sha256-0Ty9bdgdApBwG6RRFF7H6/Wm10Iiva78ErYu9vVqH9Y=" [ ])
    #   ps.jupyterlab
    #   ps.notebook
    #   ps.jupyter_console
    #   ps.ipykernel
    #   ps.pandas
    #   ps.scikitlearn
    #   ps.matplotlib
    #   ps.numpy
    #   ps.scipy
    #   ps.pip
    #   ps.seaborn
    #   ps.plotly
    #   ps.statsmodels
    #   ps.opencv4
    #   ps.selenium
    #   ps.torch
    #   ps.scikit-image
    #   ps.onnxruntime
    #   ps.pillow
    #   ps.torchvision
    # ]))

    # awscli2
    # dos2unix
    # ffmpeg-full
    # ffmpegthumbnailer
    # flameshot
    # git-annex
    # gitbutler
    # handbrake
    # httpie
    # inxi
    # nmap
    # yt-dlp
    # gvfs
    # cmake
    # fontconfig
    # most
    # libsecret
    # beekeeper-studio #broken valgrind
    # llvm
    # lldb
    # bintools
    # xorriso
    # lld
    # radare2
    # # iaito
    # virt-manager
    # qemu_full
    # pciutils
    # usbutils
    # glade
    # pkg-config
    # vlc
    # mpv
    # psmisc
    # sqlite
    # tunnelto
    # file
    # lsof
    # firefox
    # blender
    # nix-prefetch-scripts
    # qalculate-qt
    # qbittorrent
    # alacritty
    # xournalpp
    # du-dust
    # eza
    # exercism
    # dune_3
    # ocaml
    # opam
    # ocamlPackages.findlib
    # ocamlPackages.ocaml-lsp
    # dotnet-sdk
    # microsoft-edge
    # prefetch-npm-deps
    # go-swag
    # xdg-user-dirs
    # html-tidy
    # pmutils
    # unigine-valley
    # unigine-heaven
    # unigine-superposition
    # phoronix-test-suite
    # smem
    # teams
    # vagrant
    # tmate
    # redis
    # imagemagick
    # poppler_utils
    # pomodoro
    # calibre
    # mediainfo
    # rust-script
    # djvu2pdf
    # djvulibre
    # colorpicker
    # cargo-tarpaulin
    # mods
    # glow
    # gum
    # geckodriver
    # patchelf
    # bunyan-rs
    # cargo-generate
    # deno
    # ghc
    # cabal-install
    # winbox
    # texlive.combined.scheme-full
    # tor-browser-bundle-bin
    # nixpacks
    # license-cli
    # fim
    # ascii-image-converter
    # atlas
    # postgresql
    # w3m
    # cargo-watch
    # yazi
    # vesktop
    # smartmontools
    # nvme-cli
    # chntpw
    # cargo-zigbuild
    # libarchive
    # rpi-imager
    # distrobox
    # termscp
    # quick-lint-js
    # renderdoc
    # bottles
    # godot3
    # godot_4
    # onedrive
    # zig
    # swiProlog
    # wol
    # subversionClient
    # hexyl
    # waifu2x-converter-cpp
    # codux
    # gleam
    # sidequest
    # revanced-cli
    # toilet
    # bacon
    # evcxr
    # ghostscript
    # php83
    # php83Packages.composer
    # nodePackages.intelephense
    # bruno
    # cargo-flamegraph
    # measureme
    # mold
    # nixfmt-classic
    # nodePackages.prettier
    # nix-output-monitor
    # openai-whisper
    # ollama
    # nodePackages.wrangler
    # gfortran
    # gdal
    # colordiff
    # wdiff
    # dwdiff
    # cmake-format
    # cmake-language-server
  ];
}
