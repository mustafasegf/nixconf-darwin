{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-prev.url = "github:nixos/nixpkgs/release-23.11";
    staging-next.url = "github:nixos/nixpkgs/staging-next";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

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
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

    # Vim plugin inputs use "vimPlugins_" prefix, processed by lib/mkFlake2VimPlugin.nix
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
    vimPlugins_mdx = {
      url = "github:davidmh/mdx.nvim";
      flake = false;
    };
    vimPlugins_lz-n = {
      url = "github:nvim-neorocks/lz.n";
      flake = false;
    };
    vimPlugins_nvim-sops = {
      url = "github:prismatic-koi/nvim-sops";
      flake = false;
    };

    zjstatus = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    handy.url = "github:cjpais/Handy";
    handy.inputs.nixpkgs.follows = "nixpkgs";
    ghostty.url = "github:ghostty-org/ghostty";
    opencode.url = "github:anomalyco/opencode";
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      imports = [ inputs.nixos-unified.flakeModules.default ];

      perSystem =
        { system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (final: prev: {
                nushell = prev.nushell.overrideAttrs (_: {
                  doCheck = false;
                });
              })
            ];
          };
        };

      flake =
        let
          myUserName = "mustafa";
          macUserName = "mustafa.assagaf";
        in
        {
          nixosConfigurations = {
            mustafa-pc =
              let
                system = "x86_64-linux";

                upkgs = import inputs.nixpkgs-unstable {
                  inherit system;
                  config.allowUnfree = true;
                };

                ppkgs = import inputs.nixpkgs-prev {
                  inherit system;
                  config.allowUnfree = true;
                };

                staging-pkgs = import inputs.staging-next {
                  inherit system;
                  config.allowUnfree = true;
                };

                mpkgs = import inputs.nixpkgs-master {
                  inherit system;
                  config.allowUnfree = true;
                };
              in
              self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
                nixpkgs.hostPlatform = system;

                _module.args = {
                  inherit
                    inputs
                    upkgs
                    ppkgs
                    staging-pkgs
                    mpkgs
                    ;
                };

                imports = [
                  ./modules/common
                  ./modules/common/desktop.nix
                  ./modules/common/gui.nix
                  ./modules/nixos/common.nix
                  ./machines/mustafa-pc.nix
                  inputs.ucodenix.nixosModules.default
                  inputs.nix-index-database.nixosModules.nix-index
                  inputs.nix-ld.nixosModules.nix-ld
                  inputs.minegrub-theme.nixosModules.default
                  inputs.catppuccin.nixosModules.catppuccin

                  {
                    home-manager.extraSpecialArgs = {
                      inherit
                        inputs
                        upkgs
                        ppkgs
                        staging-pkgs
                        mpkgs
                        ;
                    };
                    home-manager.backupFileExtension = "hm-bak";
                    home-manager.users.${myUserName} = {
                      imports = [
                        ./home/common
                        ./home/linux
                        inputs.catppuccin.homeModules.catppuccin
                      ];
                      home.stateVersion = "24.05";
                    };
                  }
                ];
              };

            minipc = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
              nixpkgs.hostPlatform = "x86_64-linux";
              imports = [
                ./modules/common
                ./modules/nixos/common.nix
                ./machines/minipc.nix
                inputs.ucodenix.nixosModules.default
                inputs.nix-ld.nixosModules.nix-ld
                inputs.sops-nix.nixosModules.sops

                {
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${myUserName} = {
                    imports = [
                      ./home/common
                      inputs.catppuccin.homeModules.catppuccin
                    ];
                    home.stateVersion = "24.05";
                  };

                  home-manager.users."budak" = {
                    imports = [
                      ./home/common
                      inputs.catppuccin.homeModules.catppuccin
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };
          };

          darwinConfigurations = {
            Mustafa-Assagaf = self.nixos-unified.lib.mkMacosSystem { home-manager = true; } {
              nixpkgs.hostPlatform = "aarch64-darwin";
              _module.args = { inherit inputs; };
              imports = [
                ./modules/common
                ./modules/common/desktop.nix
                ./modules/common/gui.nix
                ./modules/darwin/common.nix
                inputs.nix-homebrew.darwinModules.nix-homebrew
                inputs.nix-index-database.darwinModules.nix-index
                ./machines/Mustafa-Assagaf.nix

                {
                  home-manager.backupFileExtension = "hm-bak";
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${macUserName} = {
                    imports = [
                      ./home/common
                      ./home/darwin
                      inputs.catppuccin.homeModules.catppuccin
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };

            mustafa-mac = self.nixos-unified.lib.mkMacosSystem { home-manager = true; } {
              nixpkgs.hostPlatform = "aarch64-darwin";
              _module.args = { inherit inputs; };
              imports = [
                ./modules/common
                ./modules/common/desktop.nix
                ./modules/common/gui.nix
                ./modules/darwin/common.nix
                inputs.nix-homebrew.darwinModules.nix-homebrew
                inputs.nix-index-database.darwinModules.nix-index
                ./machines/mustafa-mac.nix

                {
                  home-manager.backupFileExtension = "hm-bak";
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${myUserName} = {
                    imports = [
                      ./home/common
                      ./home/darwin
                      inputs.catppuccin.homeModules.catppuccin
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };
          };
        };
    };
}
