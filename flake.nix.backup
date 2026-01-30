{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    ucodenix.url = "github:e-tho/ucodenix";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

    # Vim plugins from flake inputs
    # prefix "vimPlugins_"
    vimPlugins_lsp-inlayhints = {
      url = "github:lvimuser/lsp-inlayhints.nvim";
      flake = false;
    };
    vimPlugins_rainbow-csv = {
      url = "github:mechatroner/rainbow_csv/3dbbfd7d17536aebfb80f571255548495574c32b";
      flake = false;
    };
    vimPlugins_blamer = {
      url = "github:APZelos/blamer.nvim";
      flake = false;
    };
    vimPlugins_vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
    vimPlugins_opencode = {
      url = "github:nickjvandyke/opencode.nvim";
      flake = false;
    };
    vimPlugins_twoslash-queries = {
      url = "github:marilari88/twoslash-queries.nvim/b92622c7b71eceefabd02eef24236041069904b1";
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      imports = [ inputs.nixos-unified.flakeModules.default ];

      flake =
        let
          # TODO: Change username
          myUserName = "mustafa";
          macUserName = "mustafa.assagaf";

        in
        {
          # Configurations for Linux (NixOS) machines
          nixosConfigurations = {
            mustafa-pc = self.nixos-unified.lib.mkLinuxSystem 
              { home-manager = true; }
              {
              nixpkgs.hostPlatform = "x86_64-linux";
              imports = [
                self.nixosModules.common # See below for "nixosModules"!
                self.nixosModules.linux
                # Your machine's configuration.nix goes here
                ({ pkgs, ... }: {
                  # TODO: Put your /etc/nixos/hardware-configuration.nix here
                  boot.loader.grub.device = "nodev";
                  fileSystems."/" = {
                    device = "/dev/disk/by-label/nixos";
                    fsType = "btrfs";
                  };
                  system.stateVersion = "24.05";
                })
                # Your home-manager configuration
                {
                  home-manager.users.${myUserName} = {
                    imports = [
                      self.homeModules.common # See below for "homeModules"!
                      self.homeModules.linux
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };

            minipc = self.nixos-unified.lib.mkLinuxSystem 
              { home-manager = true; }
              {
              nixpkgs.hostPlatform = "x86_64-linux";
              imports = [
                self.nixosModules.terminal
                self.nixosModules.minipc
                inputs.ucodenix.nixosModules.default
                inputs.nix-ld.nixosModules.nix-ld
                ({ pkgs, lib, config, ... }: {
                  boot.initrd.availableKernelModules = [ "ehci_pci" "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
                  boot.initrd.kernelModules = [ ];
                  boot.kernelParams = ["processor.max_cstate=1"];
                  boot.kernelModules = [ "kvm-amd" ];
                  boot.extraModulePackages = [ ];

                  boot.loader.efi.canTouchEfiVariables = true;
                  boot.loader.grub.efiSupport = true;
                  boot.loader.grub.device = "nodev";

                  fileSystems."/" =
                    { device = "/dev/disk/by-uuid/0ed1f3c0-c49c-4ff6-bdbe-267bc24a997e";
                      fsType = "ext4";
                    };

                  fileSystems."/home" =
                    { device = "/dev/disk/by-uuid/c85c9b61-643c-4c2e-addc-bbb937d64e16";
                      fsType = "ext4";
                    };

                  fileSystems."/boot" =
                    { device = "/dev/disk/by-uuid/2A6D-642D";
                      fsType = "vfat";
                      options = [ "fmask=0077" "dmask=0077" ];
                    };

                  swapDevices = [ ];

                  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
                  # (the default) this is the recommended approach. When using systemd-networkd it's
                  # still possible to use this option, but it's recommended to use it in conjunction
                  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
                  networking.useDHCP = lib.mkDefault true;
                              networking.hostName = "minipc";

                  # networking.interfaces.enp1s0f0.useDHCP = lib.mkDefault true;
                  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

                  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
                  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
                  hardware.cpu.x86.msr.enable = true;
                  system.stateVersion = "24.05";
                })
                # Your home-manager configuration
                {
                  home-manager.users.${myUserName} = {
                    imports = [
                      self.homeModules.common
                    ];
                    home.stateVersion = "24.05";
                  };

                  home-manager.users."budak" = {
                    imports = [
                      self.homeModules.common
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };
          };

          # Configurations for macOS machines
          darwinConfigurations = {
            Mustafa-Assagaf = self.nixos-unified.lib.mkMacosSystem 
              { home-manager = true; }
              {
              nixpkgs.hostPlatform = "aarch64-darwin";

              imports = [
                ./pam-reattach.nix
                self.darwinModules.common # Use darwinModules instead of nixosModules
                inputs.nix-homebrew.darwinModules.nix-homebrew
                inputs.nix-index-database.darwinModules.nix-index
                {
                  nix-homebrew = {
                    # Install Homebrew under the default prefix
                    enable = true;

                    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                    enableRosetta = true;

                    # User owning the Homebrew prefix
                    user = macUserName;

                    # Optional: Declarative tap management
                    taps = {
                      "homebrew/homebrew-core" = inputs.homebrew-core;
                      "homebrew/homebrew-cask" = inputs.homebrew-cask;
                    };

                    # Optional: Enable fully-declarative tap management
                    #
                    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                    mutableTaps = false;
                  };
                }

                self.darwinModules.darwin
                # Your machine's configuration.nix goes here
                ({ pkgs, ... }: {
                  # Used for backwards compatibility, please read the changelog before changing.
                  # $ darwin-rebuild changelog
                  system.stateVersion = 4;
                })
                {
                  home-manager.users.${macUserName} = {
                    imports = [
                      self.homeModules.common
                      self.homeModules.darwin
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };

            mustafa-mac = self.nixos-unified.lib.mkMacosSystem 
              { home-manager = true; }
              {
              nixpkgs.hostPlatform = "aarch64-darwin";

              imports = [
                self.darwinModules.common # Use darwinModules instead of nixosModules
                inputs.nix-homebrew.darwinModules.nix-homebrew
                inputs.nix-index-database.darwinModules.nix-index
                {
                  nix-homebrew = {
                    # Install Homebrew under the default prefix
                    enable = true;

                    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                    enableRosetta = true;

                    # User owning the Homebrew prefix
                    user = myUserName;

                    # Optional: Declarative tap management
                    taps = {
                      "homebrew/homebrew-core" = inputs.homebrew-core;
                      "homebrew/homebrew-cask" = inputs.homebrew-cask;
                    };

                    # Optional: Enable fully-declarative tap management
                    #
                    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                    mutableTaps = false;
                  };
                }

                self.darwinModules.darwin-personal
                # Your machine's configuration.nix goes here
                ({ pkgs, ... }: {
                  # Used for backwards compatibility, please read the changelog before changing.
                  # $ darwin-rebuild changelog
                  system.stateVersion = 4;
                })

                # Setup home-manager in nix-darwin config
                {
                  home-manager.users."mustafa" = {
                    imports = [
                      self.homeModules.common
                      self.homeModules.darwin
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };

          };

          # All nixos/nix-darwin configurations are kept here.
          nixosModules = /* lua */ {
            nix.settings = {
              keep-outputs = true;
              keep-derivations = true;
              experimental-features = [ "nix-command" "flakes" ];
              # substituters = [ "https://cache.komunix.org/" ];
              # substituters = lib.mkForce [ "https://cache.nixos.org" ];
              trusted-users = [ "root" "mustafa.assagaf" ];
              fallback = true;
            };


            terminal = { pkgs, ... }: {
              environment.variables = {
                SUDO_EDITOR = "nvim";
                EDITOR = "nvim";
                VISUAL = "nvim";
                PAGER = "less";
                MANPAGER = "nvim +Man!";
              };

              environment.systemPackages = with pkgs; [
                go
                hello
                atuin
                wget
                fzf
                fzf-zsh
                zip
                unzip
                htop
                gnused
                lazygit
                cowsay
                cloc
                fd
                gdu
                ripgrep
                hyfetch
                fastfetch
                uwufetch
                man
                man-pages
                man-pages-posix
                jq
                yq-go
                kubectl
                kcat
                grpcurl
                teleport
                unixtools.procps
                pkgconf
                kubectx
                cloudflared
                spotify

                mosh
                p7zip
];

              programs.zsh.enable = true;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.allowUnsupportedSystem = true;
              nixpkgs.config.allowBroken = true; 

              services.tailscale.enable = true;

              services.ucodenix.enable = true;

              services.zerotierone = {
                enable = true;
                joinNetworks = [
                  "35c192ce9b045898" # home network
                  "8850338390eddd9b" # minecraft
                ];
              };

              systemd.services.ryzen-disable-c6 = {
                # enable = true;
                description = "Ryzen Disable C6";
                wantedBy = [ "basic.target" "suspend.target" "hibernate.target" ];
                after = [ "sysinit.target" "local-fs.target" "suspend.target" "hibernate.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = [ "${pkgs.zenstates}/bin/zenstates --c6-disable" ];
                };
                # defaultDependencies = false;
              };

              # k3 config
              networking.firewall.allowedTCPPorts = [
                6443
                8443
                25565
                8123
              ];

              services.k3s = {
                enable = true;
                extraFlags = toString [];
                role = "server";
                manifests = {
                  deployment.source = ./config/deployment/craftycontrol.yaml;
                };
                autoDeployCharts = {
                  arc = {
                    package = ./config/deployment/chart/gha-runner-scale-set-controller-0.11.0.tgz;
                    # this don't works since oci don't supported yet
                    # repo = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller";
                    # name = "gha-runner-scale-set-controller";
                    # version = "0.11.0";
                    targetNamespace = "arc-systems";
                    createNamespace = true;
                    # values = {
                    #   fullnameOverride = "arc-controller";
                    # };
                  };

                  arc-runner = {
                    package = ./config/deployment/chart/gha-runner-scale-set-0.11.0.tgz;
                    targetNamespace = "arc-runners";
                    createNamespace = true;
                    values = {
                      githubConfigUrl = "http://github.com/mustafasegf";
                      githubConfigSecret = "pre-defined-secret";
                      controllerServiceAccount.namespace="arc-system";
                      controllerServiceAccount.name="actions-runner-controller-gha-rs-controller";
                      fullnameOverride = "arc-runner";
                      runnerScaleSetName = "arc-runner";
                    };
                  };
                };
              };

              services.cloudflared = {
                enable = true;
                tunnels = {
                  "minipc" = {
                    credentialsFile = "/home/mustafa/.cloudflared/5d097ed3-3a0b-4540-a6c5-0d893c3fd004.json";
                    default = "http_status:404";
                    ingress = {
                      "mus.sh" = "http://localhost:80";
                      "mc.mus.sh" = "http://localhost:8443";
                    };
                  };
                };
              };
            };

            minipc = { pkgs, ... }: {
              users.users.${myUserName} = {
                isNormalUser = true;
                shell = pkgs.zsh;
                extraGroups = [ "wheel" "docker" ];

                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNEKM6YnhuLcLfy5FkCt+rX1M10vMS00zynI6tsta1s mustafa.segf@gmail.com"
                ];
              };


              users.users."budak" = {
                isNormalUser = true;
                shell = pkgs.zsh;
                extraGroups = [ "wheel" "docker" ];

                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNEKM6YnhuLcLfy5FkCt+rX1M10vMS00zynI6tsta1s mustafa.segf@gmail.com"
                ];
              };

              services.openssh.enable = true;
              services.netdata.enable = true;

              virtualisation.docker.enable = true;

              programs.nix-ld.dev.enable = true;
              programs.nix-ld.libraries = with pkgs; [
                # toolchain + basics
                stdenv.cc.cc
                glibc
                zlib
                openssl
                curl
                nss
                nspr
                expat
                icu
                fuse3
              ];

              environment.systemPackages = with pkgs; [
                # jdk17
                graalvm-ce
                caddy
                bun
                nodePackages.nodejs
                # python3
                (python312.withPackages(ps: [
                  ps.pip
                ]))
                (pkgs.rustPlatform.buildRustPackage rec {
                  pname = "trashy";
                  version = "c95b22";

                  src = fetchFromGitHub {
                    owner = "oberblastmeister";
                    repo = "trashy";
                    rev = "c95b22c0522f616b8700821540a1e58edcf709eb";
                    hash = "sha256-O4r/bfK33hJ6w7+p+8uqEdREGUhcaEg+Zjh/T7Bm6sY=";
                  };

                  cargoHash = "sha256-qrqhIT7FKcRmz9AWAvdbPi1uzVpkGXBJefr3y06n9F0=";

                  nativeBuildInputs = [ installShellFiles ];

                  preFixup = ''
                    installShellCompletion --cmd trash \
                      --bash <($out/bin/trash completions bash) \
                      --fish <($out/bin/trash completions fish) \
                      --zsh <($out/bin/trash completions zsh) \
                  '';
                })
              ];

              # nixpkgs.config.permittedInsecurePackages = [
              #   "python-2.7.18.8"
              # ];

            };

            # Common nixos/nix-darwin configuration shared between Linux and macOS.
            common = { pkgs, system, ... }: {
              environment.variables = {
                SUDO_EDITOR = "nvim";
                EDITOR = "nvim";
                VISUAL = "nvim";
                PAGER = "less";
                MANPAGER = "nvim +Man!";
              };

              fonts.packages = with pkgs; [
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-color-emoji
                liberation_ttf
                fira-code
                fira-code-symbols
                mplus-outline-fonts.githubRelease
                dina-font
                proggyfonts
                ibm-plex
              ]  ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

              environment.systemPackages = with pkgs; [
                hello

                # ((pkgs.vscode.override { isInsiders = true; }).overrideAttrs (oldAttrs: rec {
                #   src = (builtins.fetchTarball {
                #     url = "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
                #     sha256 = "1c52rrw24gdn5aq9159psjcqd5ajwq66grl4nbwwcxhn3clddjln";
                #   });
                #   version = "latest";
                #
                #   buildInputs = oldAttrs.buildInputs ++ [ pkgs.krb5 ];
                # }))

                # vllm # broken
                terragrunt
                opentofu
                wireguard-tools
                krew
                ossutil
                # claude-code
                confluent-platform
                ast-grep
                k9s
                # code-cursor
                kustomize
                uv
                pdftk
                moreutils
                android-tools
                mtr
                # pcsx2-bin
                prometheus-alertmanager
                prometheus
                ## go
                go
                gofumpt
                gopls
                gotools
                delve
                gotestsum
                golangci-lint
                go-tools
                bun

                ## java
                jdk
                # temurin-bin
                jdt-language-server
                maven
                gradle
                # jetbrains.idea-community-bin
                # jetbrains.goland

                iterm2
                kitty
                wget
                fzf
                fzf-zsh

                ## nix
                comma
                direnv
                nix-direnv
                nix-index
                devenv

                zip
                unzip
                # bind
                htop
                gnused

                # TODO: move to home-manager
                lf
                # TODO: enable on home manager
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

                kubectl
                kcat
                grpcurl
                teleport_16
                unixtools.procps
                pkgconf
                kubectx
                kubernetes-helm

                mosh

                # awscli2
                # dos2unix
                # ffmpeg-full
                # ffmpegthumbnailer
                # flameshot
                # git-annex
                glab
                # gitbutler
                google-cloud-sdk
                # handbrake
                # httpie
                # inxi
                # nmap
                p7zip
                scrcpy
                # trashy
                # (pkgs.rustPlatform.buildRustPackage rec {
                #   pname = "trashy";
                #   version = "c95b22";

                #   src = fetchFromGitHub {
                #     owner = "oberblastmeister";
                #     repo = "trashy";
                #     rev = "c95b22c0522f616b8700821540a1e58edcf709eb";
                #     hash = "sha256-O4r/bfK33hJ6w7+p+8uqEdREGUhcaEg+Zjh/T7Bm6sY=";
                #   };

                #   cargoHash = "sha256-5BaYjUbPjmjauxlFP0GvT5mFMyrg7Bx7tTcAgQkyQBw=";

                #   nativeBuildInputs = [ installShellFiles ];

                #   preFixup = ''
                #     installShellCompletion --cmd trash \
                #       --bash <($out/bin/trash completions bash) \
                #       --fish <($out/bin/trash completions fish) \
                #       --zsh <($out/bin/trash completions zsh) \
                #   '';

                # })
                
                # yt-dlp
                # (let
                #   packagePypi = name: ver: ref: deps:
                #     python311.pkgs.buildPythonPackage rec {
                #       pname = name;
                #       version = ver;

                #       src = python311.pkgs.fetchPypi {
                #         inherit pname version;
                #         hash = ref;
                #       };

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
                #   # (
                #   #   packagePypi
                #   #     "qtile"
                #   #     "0.22.1"
                #   #     "sha256-J8PLTXQjEWIs9aJ4Fnw76Z6kdafe9dQe6GC9PoZHj4s="
                #   #     [
                #   #       pkg-config
                #   #       libinput
                #   #       wayland
                #   #       wlroots
                #   #       libxkbcommon
                #   #       ps.setuptools-scm
                #   #       ps.xcffib
                #   #       (ps.cairocffi.override { withXcffib = true; })
                #   #       ps.setuptools
                #   #       ps.python-dateutil
                #   #       ps.dbus-python
                #   #       ps.dbus-next
                #   #       ps.mpd2
                #   #       ps.psutil
                #   #       ps.pyxdg
                #   #       ps.pygobject3
                #   #       ps.pywayland
                #   #       ps.pywlroots
                #   #       ps.xkbcommon
                #   #     ]
                #   # )
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
                #   # (packagePypi "pytorch-benchmark" "0.3.6"
                #   #   "sha256-HzbBeQlswbXU+cfhdlePZFgre/4kjoSwMcbpVbgKDhI=" [
                #   #   ])
                #   ps.scikit-image
                #   # ps.imbalanced-learn
                #   # ps.optuna
                #   ps.onnxruntime
                #   ps.pillow
                #   # ps.keras
                #   # ps.tensorflow
                #   # ps.numpydoc
                #   ps.torchvision
                #   # ps.torchaudio
                # ]))
                poetry
                rustup
                nodejs
                nodePackages.npm
                nodePackages.pnpm
                # nodePackages.sass
                # nodePackages.vercel
                
                slack
                # zoom-us
                # tdesktop
                discord
                # discord-ptb
                # libnotify
                # statix
                # terraform
                # clang
                # clang-tools

                black
                stylua
                shfmt

                pyright
                nodePackages.typescript-language-server
                # nodePackages.typescript
                tflint
                ##yamlls
                ##vimls
                # texlab
                nodePackages.vscode-langservers-extracted
                ##emmet-ls
                nodePackages_latest."@tailwindcss/language-server"
                taplo
                nodePackages.graphql-language-service-cli
                sqls
                nodePackages.svelte-language-server
                # nodePackages.grammarly-languageserver
                nodePackages."@astrojs/language-server"
                emmet-ls
                ##astro
                ##prisma
                ##jsonls
                sumneko-lua-language-server
                # nodePackages.diagnostic-languageserver
                nodePackages.bash-language-server

                # gvfs
                # cmake
                # fontconfig

                # most
                tailscale
                # libsecret
                dbeaver-bin
                # beekeeper-studio #broken valgrind
                rclone

                # llvm
                # lldb
                # bintools

                # xorriso
                # lld
                # radare2
                # # iaito
                # virt-manager
                # qemu_full
                gcc
                gdb
                k6
                semgrep
                tig

                # pciutils
                # usbutils
                
                # glade

                # pkg-config
                # vlc
                # mpv
                # psmisc
                # sqlite
                # tunnelto
                scc

                hexedit
                # file
                nasm
                bear
                zerotierone
                tree
                cookiecutter
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
                wakatime-cli
                # microsoft-edge
                # prefetch-npm-deps
                # go-swag

                # xdg-user-dirs
                # html-tidy
                # pmutils
                rar
                unrar

                # there's cve
                # unigine-valley
                # unigine-heaven
                # unigine-superposition
                # phoronix-test-suite

                # smem

                protobuf
                grpc-tools
                protoc-gen-go
                protoc-gen-doc
                # protoc-gen-rust

                # teams
                # vagrant
                # tmate
                # redis
                termshark
                wireshark
                # imagemagick
                # poppler_utils

                # pomodoro
                # calibre
                # mediainfo
                # rust-script
                # djvu2pdf
                # djvulibre
                yarn
                # colorpicker
                # cargo-tarpaulin
                # mods
                # glow
                # gum
                # geckodriver
                # mods

                # patchelf
                # bunyan-rs
                # cargo-generate
                # deno
                # bun
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
                dive
                # w3m
                # cargo-watch
                # yazi
                # vesktop
                # (vesktop.override {
                #   electron = pkgs.electron_25;
                # })
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
                inetutils
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
                nixd
                gifsicle
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
                # sqls
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
                # spotify
              ];
              programs.zsh.enable = true;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.allowUnsupportedSystem = true;
              nixpkgs.config.allowBroken = true; 

              services.tailscale.enable = true;
            };

            # NixOS specific configuration
            linux = { pkgs, ... }: {
              users.users.${myUserName}.isNormalUser = true;
              services.netdata.enable = true;
            };
            # nix-darwin specific configuration
            darwin = { pkgs, ... }: {
              # security.pam.enableSudoTouchIdAuth = true;
	            security.pam.services.sudo_local.touchIdAuth = true;

              programs.nix-index-database.comma.enable = true;

              environment.systemPackages = with pkgs; [
                pam-reattach
                hexfiend
                keycastr
                # raycast
                cyberduck
              ];
              users.users.${macUserName}.home = "/users/${macUserName}";
              # nix.useDaemon = true;
            };
          };

          # Darwin-specific modules (for macOS configurations)
          darwinModules = {
            # Common darwin configuration shared for macOS
            common = { pkgs, lib, ... }: {
              environment.variables = {
                SUDO_EDITOR = "nvim";
                EDITOR = "nvim";
                VISUAL = "nvim";
                PAGER = "less";
                MANPAGER = "nvim +Man!";
              };

              fonts.packages = with pkgs; [
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-color-emoji
                liberation_ttf
                fira-code
                fira-code-symbols
                mplus-outline-fonts.githubRelease
                dina-font
                proggyfonts
                ibm-plex
              ]  ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

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
                ## go
                go
                gofumpt
                gopls
                gotools
                delve
                gotestsum
                golangci-lint
                go-tools
                bun

                ## java
                jdk
                jdt-language-server
                maven
                gradle

                iterm2
                kitty
                wget
                fzf
                fzf-zsh

                ## nix
                comma
                direnv
                nix-direnv
                nix-index
                devenv

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

                kubectl
                kcat
                grpcurl
                teleport
                unixtools.procps
                pkgconf
                kubectx
                kubernetes-helm

                mosh

                glab
                google-cloud-sdk
                p7zip
                scrcpy
                # poetry
                rustup
                nodejs
                nodePackages.npm
                nodePackages.pnpm
                
                slack
                discord

                black
                stylua
                shfmt
                nixfmt-rfc-style

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

                tailscale
                dbeaver-bin
                rclone

                gcc
                gdb
                k6
                semgrep
                tig

                scc

                hexedit
                nasm
                bear
                zerotierone
                tree
                cookiecutter

                protobuf
                grpc-tools
                protoc-gen-go
                protoc-gen-doc

                termshark
                wireshark
                yarn

                dive

                inetutils
                rar
                unrar
              ];
              programs.zsh.enable = true;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.allowUnsupportedSystem = true;
              nixpkgs.config.allowBroken = true; 

              services.tailscale.enable = true;
            };

            # nix-darwin specific configuration
            darwin = { pkgs, ... }: {
	            security.pam.services.sudo_local.touchIdAuth = true;

              programs.nix-index-database.comma.enable = true;

              # Disable Spotlight
              system.defaults.finder.AppleShowAllExtensions = true;
              system.defaults.finder.FXEnableExtensionChangeWarning = false;
              
              # Disable Spotlight keyboard shortcut (Cmd+Space)
              system.keyboard.enableKeyMapping = true;

              environment.systemPackages = with pkgs; [
                pam-reattach
                hexfiend
                keycastr
                cyberduck
              ];
              users.users.${macUserName}.home = "/users/${macUserName}";
              
              # Run commands after activation to disable Spotlight
              system.activationScripts.postActivation.text = ''
                # Disable Spotlight indexing
                sudo mdutil -a -i off 2>/dev/null || true
                
                # Disable Spotlight keyboard shortcut
                defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
                
                # Restart affected services
                /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
              '';
            };


            darwin-personal = { pkgs, ... }: {
	            security.pam.services.sudo_local.touchIdAuth = true;
	            security.pam.services.sudo_local.reattach = true;

              programs.nix-index-database.comma.enable = true;
	            nix.enable = false;

              environment.systemPackages = with pkgs; [
                go
                pam-reattach
                hexfiend
                keycastr
                cyberduck
                pear-desktop
              ];
              users.users."${myUserName}".home = "/Users/mustafa";
            };
          };

          # All home-manager configurations are kept here.
          homeModules = {
            # Common home-manager configuration shared between Linux and macOS.
            common = { pkgs, ... }: {
              # modules = [ inputs.nix-index-database.hmModules.nix-index ];
              # programs.git.enable = true;
              # programs.starship.enable = true;
              programs.bash.enable = true;
              programs.zsh.enable = true;

              imports = [
                ./programs/btop.nix
                ./programs/kitty.nix
                # ./programs/mimeapps.nix
                ./programs/nvim.nix
                # ./programs/rofi.nix
                ./programs/tmux.nix
                ./programs/zsh.nix
                # ./programs/vscode.nix
              ];

              # Make inputs available to all modules
              _module.args = { inherit inputs; };

              programs.direnv = {
                enable = true;
                nix-direnv.enable = true;
              };
              programs.bat = {
                enable = true;
                config = {
                  theme = "Dracula";
                  tabs = "2";
                  style = "plain";
                  paging = "never";
                };
              };

              programs.fzf = let
                cmd = "fd --hidden --follow --ignore-file=$HOME/.gitignore --exclude .git";
              in {
                enable = true;
                enableBashIntegration = true;
                enableZshIntegration = true;
                defaultOptions = [ "--layout=reverse --inline-info --height=90%" ];
                defaultCommand = cmd;

                fileWidgetCommand = "${cmd} --type f";
                changeDirWidgetCommand = "${cmd} --type d";

              };

              programs.starship = {
                enable = true;
                enableZshIntegration = true;
                settings = {
                  add_newline = true;
                  format =
                    "[$symbol$version]($style)[$directory]($style)[$git_branch]($style)[$git_commit]($style)[$git_state]($style)[$git_status]($style)[$line_break]($style)[$username]($style)[$hostname]($style)[$shlvl]($style)[$jobs]($style)[$time]($style)[$status]($style)[$character]($style)";
                  line_break.disabled = true;
                  cmd_duration.disabled = true;
                  character = {
                    success_symbol = "[➜](bold green)";
                    error_symbol = "[✖](bold red)";
                    vicmd_symbol = "[❮](bold yellow)";
                  };
                  package.disabled = true;
                };
              };

              programs.git = {
                enable = true;
                userName = "Mustafa Zaki Assagaf";
                userEmail = "mustafa.segf@gmail.com";
                extraConfig = {
                  core.editor = "nvim";
                  #credential."https://github.com" = {
                  #  helper = "!/run/current-system/sw/bin/gh auth git-credential";
                  #};
                  init.defaultBranch = "master";
                  pull.rebase = false;
                  pull.ff = true;
                  url."ssh://git@source.golabs.io/".insteadOf = "https://source.golabs.io/";
                };
              };

              programs.lsd = {
                enable = true;
                # enableAliases = false;
                settings = {
                  layout = "grid";
                  blocks = [ "permission" "user" "group" "date" "size" "git" "name" ];
                  color.when = "auto";
                  date = "+%d %m(%b) %Y %a";
                  recursion = {
                    enable = false;
                    depth = 7;
                  };
                  size = "short";
                  permission = "rwx";
                  no-symlink = false;
                  total-size = false;
                  hyperlink = "auto";
                };
              };

              programs.gh = {
                enable = true;
                settings = {
                  git_protocol = "ssh";
                  editor = "nvim";
                  prompt = "enable";
                  pager = "nvim";
                  # http_unix_socket.browser = "google-chrome-stable";
                };
              };

              # programs.obs-studio = {
              #   enable = true;
              #   package = (pkgs.obs-studio.override { ffmpeg = pkgs.ffmpeg-full; });
              #   plugins = with pkgs.obs-studio-plugins; [
              #     # obs-multi-rtmp
              #     obs-backgroundremoval
              #     obs-pipewire-audio-capture
              #     obs-move-transition
              #     input-overlay
              #     obs-vkcapture
              #     obs-vaapi
              #     obs-tuna
              #     obs-transition-table
              #     obs-text-pthread
              #     obs-source-switcher
              #     obs-pipewire-audio-capture
              #     input-overlay
              #   ];
              # };
              home.packages = with pkgs; [ ];
            };
            # home-manager config specific to NixOS
            linux = {
              xsession.enable = true;
            };
            # home-manager config specifi to Darwin
            darwin = {pkgs,...}: {
              targets.darwin.search = "Bing";
              home.packages = with pkgs; [ 
                xcode-install
                ffmpeg-full
              ];
            };
          };
        };
    };
}

/*
 Generated by https://github.com/DeterminateSystems/nix-installer.
# See `/nix/nix-installer --version` for the version details.

build-users-group = nixbld
experimental-features = nix-command flakes
always-allow-substitutes = true
bash-prompt-prefix = (nix:$name)\040
max-jobs = auto
extra-nix-path = nixpkgs=flake:nixpkgs
upgrade-nix-store-path-url = https://install.determinate.systems/nix-upgrade/stable/universal
*/
