{
  config,
  pkgs,
  libs,
  ...
}:
{
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
