{ inputs, ... }:

{
  imports = [
    ../modules/darwin/work.nix
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

  networking = {
    hostName = "mustafa-work";
    computerName = "mustafa-work";
    localHostName = "mustafa-work";
  };

  users.users."mustafa".home = "/users/mustafa";

  system.primaryUser = "mustafa";
  system.stateVersion = 4;
}
