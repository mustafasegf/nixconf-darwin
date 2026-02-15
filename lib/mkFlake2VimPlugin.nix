inputs: pkgs:

let
  # Filter inputs that start with "vimPlugins_"
  vimPluginInputs = pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "vimPlugins_" name) inputs;

  # Build a vim plugin from a flake input
  buildVimPlugin =
    name: src:
    pkgs.vimUtils.buildVimPlugin {
      pname = pkgs.lib.removePrefix "vimPlugins_" name;
      version = src.lastModifiedDate or "custom";
      inherit src;
    };

  # Map all vimPlugin inputs to built plugins
  plugins = pkgs.lib.mapAttrs buildVimPlugin vimPluginInputs;

  # Remove the "vimPlugins_" prefix from attribute names
  pluginsWithoutPrefix = pkgs.lib.mapAttrs' (name: value: {
    name = pkgs.lib.removePrefix "vimPlugins_" name;
    inherit value;
  }) plugins;

in
pluginsWithoutPrefix
