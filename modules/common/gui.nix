{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  environment.systemPackages =
    with pkgs;
    [
      iterm2
      kitty
      postman
      dbeaver-bin
      slack
      wireshark
      qbittorrent
      (pkgs.ghidra.withExtensions (p: [
        p.ghidra-golanganalyzerextension
        pkgs.ghidra-mcp
      ]))
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      handy
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
      vlc
      mpv
      (pkgs.buildFHSEnv {
        name = "discord";
        targetPkgs =
          p: with p; [
            alsa-lib
            at-spi2-atk
            at-spi2-core
            atk
            cairo
            cups
            curl
            dbus
            expat
            glib
            gnutar
            gtk3
            gzip
            libdrm
            libnotify
            libpulseaudio
            libxkbcommon
            mesa
            nspr
            nss
            pango
            stdenv.cc.cc.lib
            systemd
            libx11
            libxscrnsaver
            libxcomposite
            libxcursor
            libxdamage
            libxext
            libxfixes
            libxi
            libxrandr
            libxrender
            libxtst
            libxcb
            libxshmfence
          ];
        runScript = pkgs.writeShellScript "discord-self-update" ''
          set -e
          DISCORD_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/discord-self-update"
          if [ ! -x "$DISCORD_DIR/Discord" ]; then
            mkdir -p "$DISCORD_DIR"
            curl --fail --location \
              "https://discord.com/api/download?platform=linux&format=tar.gz" \
              | tar -xz -C "$DISCORD_DIR" --strip-components=1
          fi
          exec "$DISCORD_DIR/Discord" "$@"
        '';
      })
    ];
}
