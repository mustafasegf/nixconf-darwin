inputs: pkgs:

let
  vimPluginInputs = pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "vimPlugins_" name) inputs;

  buildVimPlugin =
    name: src:
    pkgs.vimUtils.buildVimPlugin {
      pname = pkgs.lib.removePrefix "vimPlugins_" name;
      version = src.lastModifiedDate or "custom";
      inherit src;
    };

  plugins = pkgs.lib.mapAttrs buildVimPlugin vimPluginInputs;

  pluginsWithoutPrefix = pkgs.lib.mapAttrs' (name: value: {
    name = pkgs.lib.removePrefix "vimPlugins_" name;
    inherit value;
  }) plugins;

in
pluginsWithoutPrefix
