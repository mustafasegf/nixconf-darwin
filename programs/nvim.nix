{
  config,
  pkgs,
  libs,
  inputs,
  ...
}:
{

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withRuby = true;

    plugins =
      let
        customPlugins = import ../lib/mkFlake2VimPlugin.nix inputs pkgs;

        # Config files live flat in config/nvim/, Nix copies them into lua/plugins/
        configFiles = [
          "config"
          "color"
          "keymap"
          "sops"
          "lsp"
          "treesitter"
          "lualine"
          "bufferline"
          "autopairs"
          "autosave"
          "notify"
          "mdx"
          "opencode"
          "completion"
          "filetree"
          "telescope"
          "git"
          "dap"
          "toggleterm"
          "misc"
          "spectre"
          "refactoring"
          "todocomments"
          "flash"
          "harpoon"
          "noice"
          "neoscroll"
          "fold"
          "colorizer"
          "indentline"
          "editing"
          "session"
        ];
        pluginSpecs = pkgs.vimUtils.buildVimPlugin {
          name = "plugin-specs";
          src = pkgs.runCommand "plugin-specs-src" { } (
            ''
              mkdir -p $out/lua/plugins
            ''
            + builtins.concatStringsSep "\n" (
              map (f: "cp ${../config/nvim/${f + ".lua"}} $out/lua/plugins/${f}.lua") configFiles
            )
          );
        };

      in
      with pkgs.vimPlugins;
      [
        pluginSpecs

        # lazy.lua bootstraps everything else via lz.n
        {
          plugin = customPlugins.lz-n;
          type = "lua";
          config = builtins.readFile ../config/nvim/lazy.lua;
        }

        catppuccin-nvim
        customPlugins.nvim-sops

        nvim-lspconfig
        none-ls-nvim
        nvim-jdtls
        neoconf-nvim
        customPlugins.lsp-inlayhints

        (nvim-treesitter.withPlugins (
          _:
          nvim-treesitter.allGrammars
          ++ [
            nvim-treesitter-parsers.wgsl
            nvim-treesitter-parsers.astro
          ]
        ))

        lualine-nvim
        bufferline-nvim
        nvim-autopairs
        auto-save-nvim

        # optional = true puts them in 'opt' packpath so lz.n controls loading
        {
          plugin = blink-cmp;
          optional = true;
        }
        {
          plugin = nvim-tree-lua;
          optional = true;
        }
        nvim-web-devicons
        {
          plugin = telescope-nvim;
          optional = true;
        }
        {
          plugin = gitsigns-nvim;
          optional = true;
        }
        {
          plugin = octo-nvim;
          optional = true;
        }
        {
          plugin = vim-fugitive;
          optional = true;
        }
        customPlugins.blamer
        {
          plugin = nvim-dap;
          optional = true;
        }
        {
          plugin = nvim-dap-ui;
          optional = true;
        }
        {
          plugin = nvim-dap-virtual-text;
          optional = true;
        }
        {
          plugin = telescope-dap-nvim;
          optional = true;
        }
        {
          plugin = nvim-dap-go;
          optional = true;
        }
        {
          plugin = toggleterm-nvim;
          optional = true;
        }
        vim-dadbod
        {
          plugin = vim-dadbod-ui;
          optional = true;
        }
        (vim-dadbod-completion.overrideAttrs (old: {
          patchPhase = ''
            substituteInPlace autoload/vim_dadbod_completion.vim \
              --replace "['sql', 'mysql', 'plsql']" \
                        "['sql', 'mysql', 'plsql', 'rust']"

              substituteInPlace autoload/vim_dadbod_completion/compe.vim \
              --replace "['sql', 'mysql', 'plsql']" \
                        "['sql', 'mysql', 'plsql', 'rust']"

              substituteInPlace plugin/vim_dadbod_completion.vim \
              --replace "sql,mysql,plsql" \
                        "sql,mysql,plsql,rust"

          '';
        }))
        {
          plugin = markdown-preview-nvim;
          optional = true;
        }
        {
          plugin = trouble-nvim;
          optional = true;
        }
        {
          plugin = nvim-spectre;
          optional = true;
        }
        {
          plugin = refactoring-nvim;
          optional = true;
        }
        {
          plugin = todo-comments-nvim;
          optional = true;
        }
        {
          plugin = flash-nvim;
          optional = true;
        }
        {
          plugin = harpoon;
          optional = true;
        }
        {
          plugin = noice-nvim;
          optional = true;
        }
        nvim-notify
        dressing-nvim
        nui-nvim
        {
          plugin = neoscroll-nvim;
          optional = true;
        }
        promise-async
        {
          plugin = nvim-ufo;
          optional = true;
        }
        {
          plugin = nvim-colorizer-lua;
          optional = true;
        }
        {
          plugin = indent-blankline-nvim;
          optional = true;
        }
        rainbow-delimiters-nvim
        {
          plugin = comment-nvim;
          optional = true;
        }
        nvim-ts-context-commentstring
        {
          plugin = nvim-surround;
          optional = true;
        }
        {
          plugin = customPlugins.vim-maximizer;
          optional = true;
        }
        {
          plugin = registers-nvim;
          optional = true;
        }
        {
          plugin = auto-session;
          optional = true;
        }
        {
          plugin = nvim-config-local;
          optional = true;
        }

        {
          plugin = customPlugins.rainbow-csv;
        }
        customPlugins.mdx

        vim-android
        otter-nvim
        nvim-ts-autotag
        vim-move
        vim-visual-multi

        customPlugins.opencode
        customPlugins.twoslash-queries

        popup-nvim
        plenary-nvim
        vim-suda
      ];
  };
}
