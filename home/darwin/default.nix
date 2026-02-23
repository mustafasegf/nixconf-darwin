{
  pkgs,
  lib,
  osConfig ? { },
  ...
}:

{
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
