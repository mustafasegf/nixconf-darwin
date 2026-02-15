{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Sops configuration for all machines
  # Automatically converts SSH key to age format for sops
  # This allows the same SSH key to decrypt secrets across all machines

  # Install ssh-to-age tool
  home.packages = [
    pkgs.ssh-to-age
    pkgs.sops
  ];

  # Create activation script to generate age key from SSH key
  home.activation.setupSopsKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Create sops age directory
    $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/sops/age

    # Find SSH key
    SSH_KEY=""
    if [ -f ${config.home.homeDirectory}/.ssh/id_ed25519 ]; then
      SSH_KEY="${config.home.homeDirectory}/.ssh/id_ed25519"
    elif [ -f ${config.home.homeDirectory}/.ssh/id_rsa ]; then
      SSH_KEY="${config.home.homeDirectory}/.ssh/id_rsa"
    elif [ -f ${config.home.homeDirectory}/.ssh/id ]; then
      SSH_KEY="${config.home.homeDirectory}/.ssh/id"
    fi

    # Convert SSH key to age format if key exists
    if [ -n "$SSH_KEY" ] && [ -f "$SSH_KEY" ]; then
      $DRY_RUN_CMD ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i "$SSH_KEY" \
        > ${config.home.homeDirectory}/.config/sops/age/keys.txt
      $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.config/sops/age/keys.txt
      $VERBOSE_ECHO "Sops age key generated from SSH key: $SSH_KEY"
    else
      $VERBOSE_ECHO "No SSH key found for sops age key generation"
    fi
  '';

  # Set environment variable for sops to find the key
  home.sessionVariables = {
    SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
