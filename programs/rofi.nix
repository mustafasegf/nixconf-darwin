{
  config,
  pkgs,
  libs,
  ...
}:
{
  # Rofi is installed via home.packages with wrapped plugins
  # Config is managed via xdg.configFile in home/linux/default.nix
  home.packages = with pkgs; [
    (rofi.override {
      plugins = [
        rofi-calc
        rofi-emoji
        rofi-pass
        rofi-systemd
      ];
    })
  ];
}
