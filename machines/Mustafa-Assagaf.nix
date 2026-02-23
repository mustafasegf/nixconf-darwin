{ inputs, ... }:

{
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

  users.users."mustafa.assagaf".home = "/users/mustafa.assagaf";

  system.stateVersion = 4;
}
