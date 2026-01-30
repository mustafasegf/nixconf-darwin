{ pkgs, ... }:

{
  # Work Mac profile (for corporate/work machines)
  # Used by machines like Mustafa-Assagaf

  # Finder configuration
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.finder.FXEnableExtensionChangeWarning = false;

  # Keyboard configuration
  system.keyboard.enableKeyMapping = true;

  # Run commands after activation to disable Spotlight
  system.activationScripts.postActivation.text = ''
    # Disable Spotlight indexing
    sudo mdutil -a -i off 2>/dev/null || true

    # Disable Spotlight keyboard shortcut
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

    # Restart affected services
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
