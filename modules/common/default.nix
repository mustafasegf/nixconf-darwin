{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./packages.nix
  ];

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    MANPAGER = "nvim +Man!";
  };

  fonts.packages =
    with pkgs;
    [
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
    ]
    ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "mustafa.assagaf"
      "mustafa"
    ];
    substituters = [
      "https://ghostty.cachix.org"
    ];
    trusted-public-keys = [
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
    ];
    fallback = true;
  };

  programs.zsh.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
    allowBroken = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      # Use jdrouhard's patched mosh fork:
      # - OSC 52 clipboard support for tmux (PR #1104)
      # - SSH agent forwarding (PR #1297)
      # - Undercurl/underline color support
      # - Unicode 16 width tables
      # - Dim and strikethrough support (PR #1059)
      # https://github.com/jdrouhard/mosh/tree/patched
      mosh = prev.mosh.overrideAttrs (old: rec {
        version = "1.4.0-patched-2025-08-24";
        src = prev.fetchFromGitHub {
          owner = "jdrouhard";
          repo = "mosh";
          rev = "3d613c845cae0b8966a5d5dbadf2639a9e2f6fd8";
          hash = "sha256-I0YlND+B7MigFKQg+nnTFQb/li+D5oe/CFwoAc9eODg=";
        };
        patches = builtins.filter (
          p:
          let
            name = builtins.baseNameOf (builtins.toString p);
          in
          builtins.elem name [
            "ssh_path.patch"
            "mosh-client_path.patch"
            "bash_completion_datadir.patch"
          ]
        ) (old.patches or [ ]);
      });

      # Handy - offline speech-to-text (https://github.com/cjpais/Handy)
      # Linux: built from source via the upstream flake
      # macOS: pre-built app bundle from GitHub releases
      ghidra-mcp = prev.callPackage ../../pkgs/ghidra-mcp { };

      handy =
        if prev.stdenv.hostPlatform.isLinux then
          inputs.handy.packages.${prev.stdenv.hostPlatform.system}.handy
        else
          prev.stdenv.mkDerivation rec {
            pname = "handy";
            version = "0.7.7";

            src = prev.fetchurl (
              if prev.stdenv.hostPlatform.isAarch64 then
                {
                  url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_aarch64.app.tar.gz";
                  hash = "sha256-qsSxZJHe4uf0+DEgLTSFolv+Hm1IV1T2vr5RzYVtp6U=";
                }
              else
                {
                  url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_x64.app.tar.gz";
                  hash = "sha256-/X26tirmdcZNM9vDcqYqqj8grQm7lmf7Ef9PNcE5AW0=";
                }
            );

            sourceRoot = ".";

            nativeBuildInputs = [ prev.gnutar ];

            installPhase = ''
              runHook preInstall
              mkdir -p $out/Applications
              cp -r Handy.app $out/Applications/
              runHook postInstall
            '';

            meta = {
              description = "A free, open source, and extensible speech-to-text application that works completely offline";
              homepage = "https://github.com/cjpais/Handy";
              license = lib.licenses.mit;
              mainProgram = "Handy";
              platforms = [
                "aarch64-darwin"
                "x86_64-darwin"
              ];
            };
          };
    })
  ];

  services.tailscale.enable = true;
}
