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
    max-jobs = 1;
    substituters = [
      "https://ghostty.cachix.org"
      "https://devenv.cachix.org"
      "https://claude-code.cachix.org"
    ];
    trusted-public-keys = [
      "ghostty.cachix.org-1:QB389yTa6gTyneehvqG58y0WnHjQOqgnA+wBnpWWxns="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
    fallback = true;
  };

  programs.zsh.enable = true;

  nixpkgs.config = {
    allowAliases = false;
    allowUnfree = true;
    allowUnsupportedSystem = true;
    allowBroken = true;
    allowInsecurePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "sidequest"
        "beekeeper-studio"
        "ventoy"
      ];
  };

  nixpkgs.overlays = [
    (final: prev: {
      obs-studio-plugins = prev.obs-studio-plugins // {
        obs-source-switcher = prev.obs-studio-plugins.obs-source-switcher.overrideAttrs (o: {
          NIX_CFLAGS_COMPILE = (o.NIX_CFLAGS_COMPILE or "") + " -Wno-error";
        });
      };

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

      # nixpkgs ships xcodes 1.6.2, whose Apple ID login has been broken since
      # Apple changed their auth endpoint (XcodesOrg/xcodes#447). 2.x fixes it,
      # but bumping the source build would require regenerating the swiftpm2nix
      # lockfile, so use the signed prebuilt release binary instead.
      xcodes = prev.stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "xcodes";
        version = "2.1.0";
        src = prev.fetchzip {
          url = "https://github.com/XcodesOrg/xcodes/releases/download/${finalAttrs.version}/xcodes.zip";
          hash = "sha256-yffHopseb030I95h0aTwlTk5Qbsmz5AB7ZjHnrX2wD4=";
          stripRoot = false;
        };
        nativeBuildInputs = [ prev.makeWrapper ];
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          install -D $src/xcodes $out/bin/xcodes
          wrapProgram $out/bin/xcodes \
            --prefix PATH : ${prev.lib.makeBinPath [ prev.aria2 ]}
          runHook postInstall
        '';
        meta = prev.xcodes.meta // {
          sourceProvenance = [ prev.lib.sourceTypes.binaryNativeCode ];
        };
      });

      # libserdes 8.1.0 fails to compile against the avro-c++/fmt in current
      # nixpkgs, so build kcat without Avro/Schema Registry support.
      kcat = prev.kcat.overrideAttrs (old: {
        buildInputs = prev.lib.remove prev.libserdes old.buildInputs;
      });

      # Current Qt deprecates Q_OS_MAC as an error on macOS, and qBittorrent
      # still uses it, so rename it to Q_OS_MACOS.
      qbittorrent =
        if prev.stdenv.hostPlatform.isDarwin then
          prev.qbittorrent.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              grep -rlw Q_OS_MAC src | xargs sed -i 's/\bQ_OS_MAC\b/Q_OS_MACOS/g'
            '';
          })
        else
          prev.qbittorrent;

      # Bump to 0.44.0 for the `ast-grep outline` subcommand, which is not
      # yet available in the pinned nixpkgs (still on 0.43.0).
      ast-grep = prev.ast-grep.overrideAttrs (old: rec {
        version = "0.44.0";
        src = prev.fetchFromGitHub {
          owner = "ast-grep";
          repo = "ast-grep";
          tag = version;
          hash = "sha256-KTVyG2z2Vx4mLmkiwou4X04Z6qzpQxmwRCtcmG4euVA=";
        };
        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit src;
          name = "${old.pname}-${version}";
          hash = "sha256-slFovLzLaK6DlTF/LKI74PUWXi9xkpy9hC9WWGmypcM=";
        };
      });

      # Handy - offline speech-to-text (https://github.com/cjpais/Handy)
      # Linux: built from source via the upstream flake
      # macOS: pre-built app bundle from GitHub releases
      ghidra-mcp = prev.callPackage ../../pkgs/ghidra-mcp { };
      linear-cli = prev.callPackage ../../pkgs/linear-cli { };
      slackcli = prev.callPackage ../../pkgs/slackcli { };
      outline-cli = prev.callPackage ../../pkgs/outline-cli { };
      playwriter = prev.callPackage ../../pkgs/playwriter { };
      oh-my-pi = prev.callPackage ../../pkgs/oh-my-pi { };
      bootvine = prev.callPackage ../../pkgs/bootvine { };

      # ffmpeg-full deps whose test suites get SIGKILLed in the macOS nix
      # sandbox (OOM-style kills under memory pressure); skip checks.
      kvazaar = prev.kvazaar.overrideAttrs (_: {
        doCheck = false;
      });
      chromaprint = prev.chromaprint.overrideAttrs (_: {
        doCheck = false;
      });

      nushell = prev.nushell.overrideAttrs (_: {
        doCheck = false;
      });

      # test017-syncreplication-refresh is flaky in this nixpkgs rev and blocks FHS apps.
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });

      # This package can spawn several memory-heavy cc1plus processes and get SIGKILLed.
      krita-plugin-gmic = prev.krita-plugin-gmic.overrideAttrs (_: {
        enableParallelBuilding = false;
      });

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
