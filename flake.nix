{
  inputs = {
    # Core inputs
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

    # Homebrew
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # Utilities
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";

    # Flake framework
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

    # Vim plugins from flake inputs (prefix "vimPlugins_")
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

      flake =
        let
          myUserName = "mustafa";
          macUserName = "mustafa.assagaf";
        in
        {
          # NixOS Configurations
          nixosConfigurations = {
            # Desktop Linux machine
            mustafa-pc =
              let
                system = "x86_64-linux";

                # Multiple nixpkgs instances for different versions
                pkgs = import inputs.nixpkgs {
                  inherit system;
                  config.allowUnfree = true;
                };

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

                # Make all package sets available
                _module.args = {
                  inherit
                    inputs
                    pkgs
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

                  # Home-manager configuration
                  {
                    home-manager.extraSpecialArgs = {
                      inherit
                        inputs
                        pkgs
                        upkgs
                        ppkgs
                        staging-pkgs
                        mpkgs
                        ;
                    };
                    home-manager.users.${myUserName} = {
                      imports = [
                        ./home/common
                        ./home/linux
                      ];
                      home.stateVersion = "24.05";
                    };
                  }
                ];
              };

            # Server Linux machine
            minipc = self.nixos-unified.lib.mkLinuxSystem { home-manager = true; } {
              nixpkgs.hostPlatform = "x86_64-linux";
              imports = [
                ./modules/common
                ./modules/nixos/common.nix
                ./machines/minipc.nix
                inputs.ucodenix.nixosModules.default
                inputs.nix-ld.nixosModules.nix-ld

                # Home-manager configuration
                {
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${myUserName} = {
                    imports = [
                      ./home/common
                    ];
                    home.stateVersion = "24.05";
                  };

                  home-manager.users."budak" = {
                    imports = [
                      ./home/common
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };
          };

          # macOS (Darwin) Configurations
          darwinConfigurations = {
            # Work Mac
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

                # Home-manager configuration
                {
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${macUserName} = {
                    imports = [
                      ./home/common
                      ./home/darwin
                    ];
                    home.stateVersion = "24.05";
                  };
                }
              ];
            };

            # Personal Mac
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

                # Home-manager configuration
                {
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.users.${myUserName} = {
                    imports = [
                      ./home/common
                      ./home/darwin
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
