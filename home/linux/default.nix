{
  pkgs,
  upkgs ? pkgs,
  ppkgs ? pkgs,
  staging-pkgs ? pkgs,
  mpkgs ? pkgs,
  ...
}:

{
  # Linux-specific home-manager configuration
  # Multiple package sets available: pkgs, upkgs, ppkgs, staging-pkgs, mpkgs

  imports = [
    ../../programs/rofi.nix
    ../../programs/mimeapps.nix
    ../../programs/vscode.nix
  ];

  xsession.enable = true;

  # Linux-specific services
  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true;
  services.blueman-applet.enable = true;
  services.easyeffects.enable = true;

  services.picom = {
    enable = false;
    backend = "glx";
    vSync = false;
    shadow = false;
    fade = true;
    fadeDelta = 4;
    opacityRules = [ ];
    settings = {
      invert-color-include = [ "class_g = 'PacketTracer'" ];
    };
  };

  services.gromit-mpx = {
    enable = true;
    tools = [
      {
        device = "default";
        type = "pen";
        size = 3;
      }
      {
        device = "default";
        type = "pen";
        color = "blue";
        size = 3;
        modifiers = [ "SHIFT" ];
      }
      {
        device = "default";
        type = "pen";
        color = "black";
        size = 3;
        modifiers = [ "CONTROL" ];
      }
      {
        device = "default";
        type = "pen";
        color = "white";
        size = 3;
        modifiers = [ "2" ];
      }
      {
        device = "default";
        type = "eraser";
        size = 30;
        modifiers = [ "3" ];
      }
    ];
  };

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
  };

  # XDG config files - Kvantum/lxqt/gtk Dracula theming
  xdg.configFile = {
    "Kvantum/Dracula/Dracula.kvconfig".source =
      let
        dracula-gtk = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "gtk";
          rev = "502f212d83bc67e8f0499574546b99ec6c8e16f9";
          sha256 = "1wx9nzq7cqyvpaq4j60bs8g7gh4jk8qg4016yi4c331l4iw1ymsa";
        };
      in
      "${dracula-gtk}/kde/kvantum/Dracula-purple-solid/Dracula-purple-solid.kvconfig";
    "Kvantum/Dracula/Dracula.svg".source =
      let
        dracula-gtk = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "gtk";
          rev = "502f212d83bc67e8f0499574546b99ec6c8e16f9";
          sha256 = "1wx9nzq7cqyvpaq4j60bs8g7gh4jk8qg4016yi4c331l4iw1ymsa";
        };
      in
      "${dracula-gtk}/kde/kvantum/Dracula-purple-solid/Dracula-purple-solid.svg";
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Dracula
    '';
    "lxqt/lxqt.conf".source = ../../config/dracula/lxqt/lxqt.conf;
    "lxqt/session.conf".source = ../../config/dracula/lxqt/session.conf;
    "gtk-3.0/settings.ini".source = ../../config/dracula/gtk-3.0/settings.ini;
    "gtk-2.0/gtkrc".source = ../../config/dracula/gtk-2.0/gtkrc-2.0;
  };

  # XDG desktop entries
  xdg.desktopEntries.ocr = {
    name = "OCR image";
    exec = "${pkgs.writeScript "ocr" ''
      ${pkgs.xfce4-screenshooter}/bin/xfce4-screenshooter -r --save /tmp/ocr-tmp.png
      ${pkgs.tesseract}/bin/tesseract /tmp/ocr-tmp.png /tmp/ocr-out
      cat /tmp/ocr-out.txt | ${pkgs.xclip}/bin/xclip -sel clip
      rm /tmp/ocr-tmp.png
    ''}";
  };

  # Xresources for Dracula theme
  xresources.extraConfig = builtins.readFile (
    pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "xresources";
      rev = "8de11976678054f19a9e0ec49a48ea8f9e881a05";
      sha256 = "12wmjynk0ryxgwb0hg4kvhhf886yvjzkp96a5bi9j0ryf3pc9kx7";
    }
    + "/Xresources"
  );

  # ========================================
  # AUTORANDR - Declarative display profiles
  # ========================================
  programs.autorandr = {
    enable = true;
    profiles.dual-4k = {
      fingerprint = {
        DP-2 = "00ffffffffffff0030aec96647414c5025200104b54627783bf795ae4f44a9260c5054adef00714f8180818a9500a9c0a9cfb300d1cf4dd000a0f0703e8030203500b9882100001a000000ff0055353131504c41470a20202020000000fd00324ba0a03c010a202020202020000000fc004c3332702d33300a202020202001ab02032ef14a01020304901112131f612309070783010000e2006a681a00000101283c00e305c000e606050161561c023a801871382d40582c4500b9882100001ecc7400a0a0a01e5030203500b9882100001a565e00a0a0a0295030203500b9882100001e0000000000000000000000000000000000000000000000000000000f";
        HDMI-1 = "00ffffffffffff006318512800000100141d0103807944780a0dc9a05747982712484c2108008140a940818081c0a9c001010101010108e80030f2705a80b0588a00b9a84200001e023a801871382d40582c4500b9a84200001e000000fc004265796f6e642054560a202020000000fd00324b1e503c000a202020202020017d020352f25a61605f6665909f051420041312110302161507060121225e5d622909070715175055170083010000e200cb6e030c001000b8442100800102030467d85dc401788807e305e301e20f1be3060f01023a801871382d40582c4500b9a84200001e011d007251d01e206e285500b9a84200001e0000000000000000005d";
      };
      config = {
        DP-2 = {
          enable = true;
          primary = true;
          mode = "3840x2160";
          position = "0x0";
          rate = "60.00";
        };
        HDMI-1 = {
          enable = true;
          mode = "3840x2160";
          position = "3840x0";
          rate = "60.00";
        };
      };
    };
  };

  # ========================================
  # XDG AUTOSTART - GUI apps at login
  # ========================================
  xdg.desktopEntries = {
    autostart-copyq = {
      name = "CopyQ";
      exec = "copyq";
      settings.X-GNOME-Autostart-enabled = "true";
    };
    autostart-thunderbird = {
      name = "Thunderbird";
      exec = "thunderbird";
      settings.X-GNOME-Autostart-enabled = "true";
    };
    autostart-nitrogen = {
      name = "Nitrogen Restore";
      exec = "nitrogen --restore";
      settings.X-GNOME-Autostart-enabled = "true";
    };
  };

  # Noisetorch - noise suppression daemon
  systemd.user.services.noisetorch = {
    Unit = {
      Description = "NoiseTorch noise suppression";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/run/wrappers/bin/noisetorch -i";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # OBS Studio with plugins
  programs.obs-studio = {
    enable = true;
    package = (pkgs.obs-studio.override { ffmpeg = pkgs.ffmpeg-full; });
    plugins = with pkgs.obs-studio-plugins; [
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-move-transition
      input-overlay
      obs-vkcapture
      obs-vaapi
      obs-tuna
      obs-text-pthread
      obs-source-switcher
    ];
  };
}
