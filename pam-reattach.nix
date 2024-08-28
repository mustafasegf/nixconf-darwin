{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security.pam;

  # Implementation Notes
  #
  # We don't use `environment.etc` because this would require that the user manually delete
  # `/etc/pam.d/sudo` which seems unwise given that applying the nix-darwin configuration requires
  # sudo. We also can't use `system.patchs` since it only runs once, and so won't patch in the
  # changes again after OS updates (which remove modifications to this file).
  #
  # As such, we resort to line addition/deletion in place using `sed`. We add a comment to the
  # added line that includes the name of the option, to make it easier to identify the line that
  # should be deleted when the option is disabled.
  mkSudoTouchIdAuthScript = isEnabled:
  let
    file   = "/etc/pam.d/sudo";
    option = "security.pam.enableSudoTouchIdReattach";
    sed = "${pkgs.gnused}/bin/sed";
    reattach = "/usr/local/lib/pam/pam_reattach.so";
  in ''
    ${if isEnabled then ''
      # create folder if not exist
      mkdir -p /usr/local/lib/pam

      # Make symlink to ${reattach}
      if [ ! -e ${reattach} ]; then
        sudo ln -sf "${pkgs.pam-reattach}/lib/pam/pam_reattach.so" ${reattach}
      fi

      # Enable sudo Touch ID authentication, if not already enabled
      if ! grep 'pam_reattach.so' ${file} > /dev/null; then
        ${sed} -i '2i\
      auth       optional    ${reattach} # nix-darwin: ${option}
        ' ${file}
      fi
    '' else ''
      # Disable sudo Touch ID authentication, if added by nix-darwin
      if grep '${option}' ${file} > /dev/null; then
        ${sed} -i '/${option}/d' ${file}
      fi

      # Remove symlink to ${reattach}
      if [ -L ${reattach} ]; then
        sudo rm -f ${reattach}
      fi
    ''}
  '';
in

{
  options = {
    security.pam.enableSudoTouchIdReattach = mkEnableOption "" // {
      description = ''
        Enable sudo authentication with Touch ID.

        When enabled, this option adds the following line to
        {file}`/etc/pam.d/sudo`:

        ```
        auth       optional     /usr/local/lib/pam/pam_reattach.so
        ```

        ::: {.note}
        macOS resets this file when doing a system update. As such, sudo
        authentication with Touch ID won't work after a system update
        until the nix-darwin configuration is reapplied.
        :::
      '';
    };
  };

  config = {
    system.activationScripts.pam.text = ''
      # PAM settings
      echo >&2 "setting up pam..."
      ${mkSudoTouchIdAuthScript cfg.enableSudoTouchIdReattach}
    '';
  };
}