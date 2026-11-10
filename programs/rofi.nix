{
  config,
  pkgs,
  ppkgs ? pkgs,
  libs,
  ...
}:
{
  home.packages = with pkgs; [
    (rofi.override {
      plugins = [
        rofi-calc
        rofi-emoji
        ppkgs.rofi-pass
        rofi-systemd
      ];
    })
  ];
}
