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
    ../../programs/qtile.nix
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

  # XDG desktop entries
  xdg.desktopEntries.ocr = {
    name = "OCR image";
    exec = "${pkgs.writeScript "ocr" ''
      ${pkgs.xfce.xfce4-screenshooter}/bin/xfce4-screenshooter -r --save /tmp/ocr-tmp.png
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
