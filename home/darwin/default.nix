{
  pkgs,
  lib,
  osConfig ? { },
  ...
}:

{
  # macOS-specific home-manager configuration

  targets.darwin.search = "Bing";

  home.packages =
    with pkgs;
    [
      ffmpeg-full
    ]
    ++ lib.optionals (osConfig.custom.enableXcode or true) [
      xcode-install
    ];
}
