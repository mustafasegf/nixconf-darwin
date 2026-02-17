{
  config,
  lib,
  pkgs,
  upkgs ? pkgs,
  ppkgs ? pkgs,
  staging-pkgs ? pkgs,
  mpkgs ? pkgs,
  ...
}:

{
  # Desktop NixOS configuration - for Linux desktop/workstation systems
  # Includes X11, Qtile, desktop services, virtualization, etc.
  #
  # Multiple package sets available:
  # - pkgs: nixpkgs (unstable)
  # - upkgs: nixpkgs-unstable (same as pkgs usually)
  # - ppkgs: nixpkgs-prev (23.11 stable)
  # - staging-pkgs: staging-next branch
  # - mpkgs: master branch (bleeding edge)

  # ========================================
  # LOCALIZATION
  # ========================================

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.utf8";
    LC_IDENTIFICATION = "id_ID.utf8";
    LC_MEASUREMENT = "id_ID.utf8";
    LC_MONETARY = "id_ID.utf8";
    LC_NAME = "id_ID.utf8";
    LC_NUMERIC = "id_ID.utf8";
    LC_PAPER = "id_ID.utf8";
    LC_TELEPHONE = "id_ID.utf8";
    LC_TIME = "id_ID.utf8";
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # ========================================
  # QT/GTK THEMING
  # ========================================

  qt = {
    enable = true;
    platformTheme = "lxqt";
    style = "adwaita-dark";
  };

  # ========================================
  # XDG PORTAL
  # ========================================

  xdg = {
    mime.enable = true;
    portal = {
      enable = true;
      xdgOpenUsePortal = true;
      lxqt.styles = with pkgs; [ libsForQt5.qtstyleplugin-kvantum ];
      config.common.default = "*";
      lxqt.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };

  # ========================================
  # ENVIRONMENT
  # ========================================

  environment.pathsToLink = [ "/share/nix-direnv" ];

  environment.variables = {
    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    BROWSER = "google-chrome-stable";
    QT_QPA_PLATFORMTHEME = "lxqt";
    GTK_USE_PORTAL = "1";
    MANPAGER = "nvim +Man!";
    TERMINAL = "kitty";
    GDK_SCALE = "1";
  };

  environment.extraInit = ''
    # Do not want SSH_ASKPASS in the environment
    unset -v SSH_ASKPASS
  '';

  # Wacom tablet configuration
  environment.etc."X11/xorg.conf.d/10-tablet.conf".source = pkgs.writeText "10-tablet.conf" ''
    Section "InputClass"
    Identifier "Tablet"
    Driver "wacom"
    MatchDevicePath "/dev/input/event*"
    MatchUSBID "256c:006d"
    EndSection
  '';

  # ========================================
  # NIX OVERLAYS
  # ========================================

  # nix-direnv flakes support is now enabled by default
  nixpkgs.overlays = [
    (final: prev: {
      # Workaround: shaderc linking is broken in this nixpkgs rev (ffmpeg 8.x)
      # https://github.com/NixOS/nixpkgs/pull/477464
      ffmpeg-full = prev.ffmpeg-full.override { withShaderc = false; };

      # Workaround: unbreak-hardcoded-tables.patch (written for ffmpeg 8.x) removes the
      # av_malloc stub from tableprint_vlc.h, but ffmpeg 7.x still uses av_malloc in vlc.c.
      # Re-add the stub so tablegen compilation works.
      handbrake = prev.handbrake.override {
        ffmpeg_7-full = prev.ffmpeg_7-full // {
          override =
            args:
            (prev.ffmpeg_7-full.override args).overrideAttrs (old: {
              postPatch = (old.postPatch or "") + ''
                if grep -q 'av_mallocz(s) NULL' libavcodec/tableprint_vlc.h 2>/dev/null && \
                   ! grep -q 'av_malloc(s) NULL' libavcodec/tableprint_vlc.h 2>/dev/null; then
                  sed -i '/define av_mallocz(s) NULL/a #define av_malloc(s) NULL' libavcodec/tableprint_vlc.h
                fi
              '';
            });
        };
      };
    })
  ];

  # ========================================
  # PROGRAMS
  # ========================================

  programs.wireshark.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-volman
    thunar-archive-plugin
    thunar-media-tags-plugin
  ];
  programs.noisetorch.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.command-not-found.enable = false;

  # Nix substituters
  nix.settings.substituters = lib.mkForce [ "https://cache.nixos.org" ];

  # musl dynamic linker for unpatched musl binaries (e.g. bun-installed CLIs)
  systemd.tmpfiles.rules = [
    "L+ /lib/ld-musl-x86_64.so.1 - - - - ${pkgs.musl}/lib/ld-musl-x86_64.so.1"
  ];
  environment.etc."ld-musl-x86_64.path".text = lib.concatStringsSep "\n" [
    "${pkgs.pkgsMusl.stdenv.cc.cc.lib}/lib"
  ];

  # nix-ld for running unpatched glibc binaries (dev version from flake)
  programs.nix-ld.dev.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Toolchain + basics
    stdenv.cc.cc
    zlib
    openssl
    curl
    nss
    nspr
    expat
    icu
    fuse3

    # X11/XCB core
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXi
    xorg.libxcb
    xorg.libXtst
    xorg.libXScrnSaver
    xorg.libXinerama
    xorg.libXdmcp
    xorg.libXau

    # XCB util modules
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm

    # Keyboard handling
    libxkbcommon
    libxkbcommon_x11

    # Fonts
    freetype
    fontconfig

    # OpenGL/EGL
    libglvnd
    mesa
  ];

  # ========================================
  # LINUX DESKTOP PACKAGES
  # ========================================

  environment.systemPackages = with pkgs; [
    ## Desktop essentials
    arandr
    copyq
    dunst
    find-cursor
    flameshot
    killall
    libnotify
    nitrogen
    pavucontrol
    ncpamixer
    pulseaudioFull
    alsa-utils
    screenkey
    xclip
    xsel
    xcolor
    scrot

    ## File managers and archive tools
    file-roller
    kdePackages.ark
    kdePackages.filelight

    ## Graphics and media
    mesa-demos
    ffmpeg-full
    ffmpegthumbnailer
    vlc
    mpv
    pinta
    krita
    blender
    gimp
    handbrake
    kdePackages.kdenlive
    imagemagick
    poppler-utils
    yt-dlp
    cheese
    webcamoid
    mangohud
    radeontop
    nvtopPackages.amd

    ## Office and productivity
    libreoffice
    kdePackages.okular
    xournalpp
    qalculate-qt
    kdePackages.kcalc
    calibre
    thunderbird

    ## Communication
    zoom-us
    telegram-desktop
    google-chrome
    firefox
    bitwarden-desktop
    bitwarden-cli

    ## Gaming
    steam
    lutris
    wine
    wine64
    winetricks
    prismlauncher
    mangohud

    ## Networking
    bind
    nmap
    httpie
    inxi
    awscli2
    x11vnc

    ## Audio tools
    qpwgraph
    helvum
    wireplumber

    ## Theming
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    lxqt.lxqt-qtplugin
    lxqt.lxqt-config
    lxappearance
    papirus-icon-theme
    dracula-theme

    ## System tools
    input-remapper
    pciutils
    usbutils
    fwupd
    psmisc
    lsof
    dos2unix
    solaar
    logitech-udev-rules
    powertop
    dmidecode
    inotify-tools
    smartmontools
    nvme-cli

    ## Development (Linux-specific)
    appimage-run
    clang
    clang-tools
    gdb
    gnumake
    cmake
    sqlite
    openssl
    musl
    nasm
    statix
    poetry
    pandoc
    texlive.combined.scheme-full
    vulkan-tools
    clinfo
    SDL2
    SDL2_ttf
    SDL2_net
    SDL2_gfx
    SDL2_sound
    SDL2_mixer
    SDL2_image
    virt-manager
    docker
    distrobox

    ## Xorg tools
    xorg.xkbcomp
    xorg.xkbutils
    xorg.xmodmap
    xorg.xinput
    xorg.libX11
    xorg.libXft
    xorg.libXinerama

    ## Misc
    home-manager
    openrgb
    tor-browser
    qbittorrent
    seahorse
    cloudflare-warp
    spotify
    parsec-bin
    chafa

    ## Python scientific stack
    (python3.withPackages (ps: [
      ps.jupyterlab
      ps.notebook
      ps.jupyter-console
      ps.ipykernel
      ps.pandas
      ps.scikit-learn
      ps.matplotlib
      ps.numpy
      ps.scipy
      ps.pip
      ps.statsmodels
      ps.opencv4
      ps.selenium
      ps.scikit-image
      ps.onnxruntime
      ps.pillow
      ps.tkinter
    ]))
  ];

  # ========================================
  # SERVICES - DESKTOP
  # ========================================

  services.dbus.packages = with pkgs; [
    dconf
    gnome-keyring
  ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  services.udisks2.enable = true;
  services.printing.enable = true;
  services.blueman.enable = true;
  services.picom.enable = false;
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # ========================================
  # SERVICES - X11 & QTILE
  # ========================================

  services.displayManager.defaultSession = "qtile";

  services.xserver = {
    enable = true;
    digimend.enable = false;
    wacom.enable = true;
    videoDrivers = [ "modesetting" ];

    autorun = true;
    displayManager = {
      lightdm = {
        enable = true;
        greeter.enable = true;
      };

      # Remap F13-F24 keys (for tablet buttons)
      sessionCommands =
        let
          functionkey = pkgs.writeText "xkb-layout" ''
            keycode 191 = F13 F13 F13
            keycode 192 = F14 F14 F14
            keycode 193 = F15 F15 F15
            keycode 194 = F16 F16 F16
            keycode 195 = F17 F17 F17
            keycode 196 = F18 F18 F18
            keycode 197 = F19 F19 F19
            keycode 198 = F20 F20 F20
            keycode 199 = F21 F21 F21
            keycode 200 = F22 F22 F22
            keycode 201 = F23 F23 F23
            keycode 202 = F24 F24 F24
          '';
        in
        ''
          sleep 5 && ${pkgs.xorg.xmodmap}/bin/xmodmap ${functionkey}
          gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
        '';
    };

    windowManager.qtile = {
      enable = true;
    };
  };

  # ========================================
  # SERVICES - AUDIO
  # ========================================

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ========================================
  # SERVICES - NETWORK
  # ========================================

  services.openssh.enable = true;
  services.tor = {
    enable = true;
    client.enable = true;
  };

  # xrdp remote desktop
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${config.services.xserver.windowManager.qtile.finalPackage}/bin/qtile start x11";
  services.xrdp.openFirewall = true;

  # OpenVPN
  services.openvpn.servers = {
    uihpc = {
      config = "config /home/mustafa/openvpn/hpc12.ovpn ";
    };
  };

  # ========================================
  # SECURITY
  # ========================================

  security.sudo.configFile = ''
    mustafa ALL = NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff
  '';

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    })
  '';

  # ========================================
  # VIRTUALIZATION
  # ========================================

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      debug = true;
      metrics-addr = "0.0.0.0:9323";
      default-address-pools = [
        {
          base = "172.17.0.0/12";
          size = 24;
        }
        {
          base = "192.168.0.0/16";
          size = 24;
        }
      ];
    };
  };

  virtualisation.virtualbox.host = {
    enable = false;
    enableExtensionPack = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.runAsRoot = true;
  };

  users.extraGroups.vboxusers.members = [ "mustafa" ];

  # ========================================
  # SYSTEMD SERVICES
  # ========================================

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.services.pcscd.enable = false;
  systemd.sockets.pcscd.enable = false;

  # Polkit authentication agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # Tailscale auto-connect
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      sleep 2
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then
        exit 0
      fi
      ${tailscale}/bin/tailscale up
    '';
  };

  # Prevent sleep while libvirt VMs are running
  systemd.services."libvirt-nosleep@" = {
    enable = true;
    description = ''Preventing sleep while libvirt domain "%i" is running'';
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.systemd}/bin/systemd-inhibit --what=sleep --why=" Libvirt domain \"%i\" is running" --who=%U --mode=block sleep infinity'';
    };
  };

  systemd.services.libvirtd = {
    enable = true;
    path =
      let
        env = pkgs.buildEnv {
          name = "qemu-hook-env";
          paths = with pkgs; [
            bash
            libvirt
            kmod
            systemd
            ripgrep
            sd
            pciutils
            procps
            gawk
          ];
        };
      in
      [ env ];
  };

  # Cloudflare WARP
  systemd.services.warp-svc.enable = true;
  systemd.packages = with pkgs; [ cloudflare-warp ];

  # ========================================
  # DOCUMENTATION
  # ========================================

  documentation.man.generateCaches = true;
  documentation.dev.enable = true;
}
