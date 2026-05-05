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

  # Automatically converts SSH key to age format for sops decryption
  home.activation.setupSopsKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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

  home.activation.setupNixUserConf = lib.hm.dag.entryAfter [ "setupSopsKey" ] ''
    if [ -f ${config.home.homeDirectory}/.config/sops/age/keys.txt ]; then
      if TOKEN=$(SOPS_AGE_KEY_FILE=${config.home.homeDirectory}/.config/sops/age/keys.txt \
        ${pkgs.sops}/bin/sops -d --extract '["github_token"]' ${../../secrets/nix.yaml} 2>/dev/null); then
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/nix
        umask 077
        {
          printf 'access-tokens = github.com=%s\n' "$TOKEN"
          printf 'extra-substituters = https://devenv.cachix.org\n'
          printf 'extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=\n'
        } > ${config.home.homeDirectory}/.config/nix/nix.conf
        $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.config/nix/nix.conf
        $VERBOSE_ECHO "Wrote ~/.config/nix/nix.conf"
      else
        $VERBOSE_ECHO "Could not decrypt secrets/nix.yaml — skipping nix.conf"
      fi
    fi
  '';
}
