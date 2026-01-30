{ pkgs, ... }:

{
  # This file now just imports base.nix for truly common packages
  # For desktop systems, also import desktop.nix and gui.nix
  imports = [
    ./base.nix
  ];

  # Commented out packages that should only be on desktop systems
  # These are now in desktop.nix and gui.nix
  environment.systemPackages = with pkgs; [
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
