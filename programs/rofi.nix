{
  config,
  pkgs,
  libs,
  ...
}:
{
  programs.rofi = {
    enable = true;

    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-pass
      rofi-systemd
    ];
    font = "IBM Plex Mono 12";

    # Theme is defined in xdg.configFile."rofi/config.rasi" below
  };
}
