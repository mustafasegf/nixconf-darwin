{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Qtile window manager configuration
  # This is Linux-only, so it will only be imported on NixOS systems

  # The actual Qtile service configuration is in the machine config
  # This file just sets up home-manager XDG configs

  xdg.configFile = {
    "qtile/config.py".source = ../config/qtile/config.py;
    "qtile/floating_window_snapping.py".source = ../config/qtile/floating_window_snapping.py;
    "qtile/autostart.sh".source = ../config/qtile/autostart.sh;
  };
}
