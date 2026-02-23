{
  pkgs,
  upkgs ? pkgs,
  ppkgs ? pkgs,
  staging-pkgs ? pkgs,
  mpkgs ? pkgs,
  ...
}:

{
  imports = [
    ../../programs/rofi.nix
    ../../programs/mimeapps.nix
    ../../programs/vscode.nix
  ];

  xsession.enable = true;

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

  gtk.enable = true;

  xdg.configFile = {
    "lxqt/lxqt.conf".source = ../../config/catppuccin/lxqt/lxqt.conf;
    "lxqt/session.conf".source = ../../config/catppuccin/lxqt/session.conf;
    "rofi/config.rasi".source = ../../config/rofi/config.rasi;
  };

  xdg.desktopEntries.ocr = {
    name = "OCR image";
    exec = "${pkgs.writeScript "ocr" ''
      ${pkgs.xfce4-screenshooter}/bin/xfce4-screenshooter -r --save /tmp/ocr-tmp.png
      ${pkgs.tesseract}/bin/tesseract /tmp/ocr-tmp.png /tmp/ocr-out
      cat /tmp/ocr-out.txt | ${pkgs.xclip}/bin/xclip -sel clip
      rm /tmp/ocr-tmp.png
    ''}";
  };

  xresources.extraConfig = ''
    ! Catppuccin Mocha
    *background: #1e1e2e
    *foreground: #cdd6f4
    *cursorColor: #f5e0dc

    ! black
    *color0: #45475a
    *color8: #585b70

    ! red
    *color1: #f38ba8
    *color9: #f38ba8

    ! green
    *color2: #a6e3a1
    *color10: #a6e3a1

    ! yellow
    *color3: #f9e2af
    *color11: #f9e2af

    ! blue
    *color4: #89b4fa
    *color12: #89b4fa

    ! magenta
    *color5: #f5c2e7
    *color13: #f5c2e7

    ! cyan
    *color6: #94e2d5
    *color14: #94e2d5

    ! white
    *color7: #bac2de
    *color15: #a6adc8
  '';

  programs.autorandr = {
    enable = true;
    profiles.dual-4k = {
      fingerprint = {
        DP-2 = "00ffffffffffff0030aec96647414c5025200104b54627783bf795ae4f44a9260c5054adef00714f8180818a9500a9c0a9cfb300d1cf4dd000a0f0703e8030203500b9882100001a000000ff0055353131504c41470a20202020000000fd00324ba0a03c010a202020202020000000fc004c3332702d33300a202020202001ab02032ef14a01020304901112131f612309070783010000e2006a681a00000101283c00e305c000e606050161561c023a801871382d40582c4500b9882100001ecc7400a0a0a01e5030203500b9882100001a565e00a0a0a0295030203500b9882100001e0000000000000000000000000000000000000000000000000000000f";
        HDMI-1 = "00ffffffffffff006318522800000100141d0103807944780a0dc9a05747982712484c2108008140a940818081c0a9c001010101010108e80030f2705a80b0588a00b9a84200001e023a801871382d40582c4500b9a84200001e000000fc004265796f6e642054560a202020000000fd00324b1e503c000a202020202020017d020352f25a61605f6665909f051420041312110302161507060121225e5d622909070715175055170083010000e200cb6e030c001000b8442100800102030467d85dc401788807e305e301e20f1be3060f01023a801871382d40582c4500b9a84200001e011d007251d01e206e285500b9a84200001e0000000000000000005d";
      };
      config = {
        DP-2 = {
          enable = true;
          mode = "3840x2160";
          position = "0x0";
          rate = "60.00";
        };
        HDMI-1 = {
          enable = true;
          primary = true;
          mode = "3840x2160";
          position = "3840x0";
          rate = "60.00";
        };
      };
    };
  };

  xdg.configFile."autostart/copyq.desktop".text = ''
    [Desktop Entry]
    Name=CopyQ
    Exec=copyq
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';

  xdg.configFile."autostart/thunderbird.desktop".text = ''
    [Desktop Entry]
    Name=Thunderbird
    Exec=thunderbird
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';

  xdg.configFile."autostart/nitrogen.desktop".text = ''
    [Desktop Entry]
    Name=Nitrogen Restore
    Exec=nitrogen --restore
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';

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

  services.dunst.enable = true;
  programs.mpv.enable = true;
  programs.alacritty.enable = true;
  programs.mangohud.enable = true;

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
