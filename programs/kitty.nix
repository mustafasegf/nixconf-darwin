{
  config,
  pkgs,
  libs,
  ...
}:
{

  programs.kitty = {
    enable = true;
    font = {
      name = "IBM Plex Mono";
      size = 9;
    };

    settings = {
      background_opacity = "1.00";
      enable_audio_bell = false;
      confirm_os_window_close = "0";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      scrollback_lines = 6000;
      # OSC 52 clipboard - allows remote machines to copy to local clipboard
      clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask";
    };
  };
}
