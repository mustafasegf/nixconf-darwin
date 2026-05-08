{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [
    pkgs.ssh-to-age
    pkgs.sops
  ];

  # Derive the age key from the user's SSH key so sops-nix can decrypt.
  # Must run before sops-nix's activation step.
  home.activation.setupSopsKey = lib.hm.dag.entryBefore [ "sops-nix" ] ''
    $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/sops/age

    SSH_KEY=""
    if [ -f ${config.home.homeDirectory}/.ssh/id_ed25519 ]; then
      SSH_KEY="${config.home.homeDirectory}/.ssh/id_ed25519"
    elif [ -f ${config.home.homeDirectory}/.ssh/id_rsa ]; then
      SSH_KEY="${config.home.homeDirectory}/.ssh/id_rsa"
    elif [ -f ${config.home.homeDirectory}/.ssh/id ]; then
      SSH_KEY="${config.home.homeDirectory}/.ssh/id"
    fi

    if [ -n "$SSH_KEY" ] && [ -f "$SSH_KEY" ]; then
      $DRY_RUN_CMD ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i "$SSH_KEY" \
        > ${config.home.homeDirectory}/.config/sops/age/keys.txt
      $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.config/sops/age/keys.txt
      $VERBOSE_ECHO "Sops age key generated from SSH key: $SSH_KEY"
    else
      $VERBOSE_ECHO "No SSH key found for sops age key generation"
    fi
  '';

  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    age.generateKey = false;

    secrets.github_token.sopsFile = ../../secrets/nix.yaml;

    templates."nix.conf" = {
      path = "${config.home.homeDirectory}/.config/nix/nix.conf";
      content = ''
        access-tokens = github.com=${config.sops.placeholder.github_token}
      '';
    };
  };
}
