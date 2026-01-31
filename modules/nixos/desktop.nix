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

  nixpkgs.overlays = [
    (self: super: {
      nix-direnv = super.nix-direnv.override { enableFlakes = true; };
    })
  ];

  # ========================================
  # PROGRAMS
  # ========================================

  programs.wireshark.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-volman
    thunar-archive-plugin
    thunar-media-tags-plugin
  ];
  programs.noisetorch.enable = true;
  programs.dconf.enable = true;
  programs.zsh.enable = true;
  programs.adb.enable = true;
  programs.command-not-found.enable = false;

  # nix-ld for running unpatched binaries
  programs.nix-ld.enable = true;
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

  services.xserver = {
    enable = true;
    digimend.enable = false;
    wacom.enable = true;
    videoDrivers = [ "modesetting" ];

    autorun = true;
    displayManager = {
      defaultSession = "none+qtile";
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
        '';
    };

    windowManager.qtile = {
      enable = true;
      # Use ppkgs (previous stable) for Qtile - more stable than bleeding edge
      package = ppkgs.qtile;
      extraSessionCommands = "gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh";
      backend = "x11";
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
  services.xrdp.defaultWindowManager = "${ppkgs.qtile}/bin/qtile start x11";
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
