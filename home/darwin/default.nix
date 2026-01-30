{ pkgs, ... }:

{
  # macOS-specific home-manager configuration

  targets.darwin.search = "Bing";

  home.packages = with pkgs; [
    xcode-install
    ffmpeg-full
  ];
}
