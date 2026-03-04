{ inputs, ... }:

{
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

  networking.hostName = "mustafa-mac";
  networking.computerName = "mustafa-mac";
  networking.localHostName = "mustafa-mac";

  users.users."mustafa".home = "/Users/mustafa";

  system.primaryUser = "mustafa";
  system.stateVersion = 4;
}
