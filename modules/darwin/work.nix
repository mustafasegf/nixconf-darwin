{ pkgs, ... }:

{
  system = {
    defaults.finder.AppleShowAllExtensions = true;
    defaults.finder.FXEnableExtensionChangeWarning = false;
    keyboard.enableKeyMapping = true;
    activationScripts.postActivation.text = ''
      # Disable Spotlight indexing
      sudo mdutil -a -i off 2>/dev/null || true

      # Disable Spotlight keyboard shortcut
      defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

      # Restart affected services
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  homebrew.casks = [
    "karabiner-elements"
    "notion-mail"
    "notion-calendar"
    "linear-linear"
  ];
}
