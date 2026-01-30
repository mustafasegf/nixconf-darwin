{ inputs, ... }:

{
  # Machine-specific configuration for Mustafa-Assagaf (Work Mac)
  # NOTE: nix-homebrew modules are imported at flake level

  imports = [
    ../modules/darwin/work.nix
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "mustafa.assagaf";

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    mutableTaps = false;
  };

  # User configuration
  users.users."mustafa.assagaf".home = "/users/mustafa.assagaf";

  # System version
  system.stateVersion = 4;
}
