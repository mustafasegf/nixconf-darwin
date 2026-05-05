inputs: pkgs:

let
  vimPluginInputs = pkgs.lib.filterAttrs (name: _: pkgs.lib.hasPrefix "vimPlugins_" name) inputs;

  buildVimPlugin =
    name: src:
    pkgs.vimUtils.buildVimPlugin {
      pname = pkgs.lib.removePrefix "vimPlugins_" name;
      version = src.lastModifiedDate or "custom";
      inherit src;
      # Skip the neovim require-check hook — some plugins (e.g. mdx.nvim) call
      # vim.fn.system("git …") at require time, which fails in the sandboxed
      # build with no git on PATH.
      doCheck = false;
    };

  plugins = pkgs.lib.mapAttrs buildVimPlugin vimPluginInputs;

  pluginsWithoutPrefix = pkgs.lib.mapAttrs' (name: value: {
    name = pkgs.lib.removePrefix "vimPlugins_" name;
    inherit value;
  }) plugins;

in
pluginsWithoutPrefix
