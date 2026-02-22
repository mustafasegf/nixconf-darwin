{ inputs, ... }:

{
  # Machine-specific configuration for mustafa-mac (Personal Mac)
  # NOTE: nix-homebrew modules are imported at flake level

  imports = [
    ../modules/darwin/personal.nix
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "mustafa";

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    mutableTaps = false;
  };

  # Hostname configuration
  networking.hostName = "mustafa-darwin";
  networking.computerName = "mustafa-darwin";
  networking.localHostName = "mustafa-darwin";

  # User configuration
  users.users."mustafa".home = "/Users/mustafa";

  # System version
  system.stateVersion = 4;
}
