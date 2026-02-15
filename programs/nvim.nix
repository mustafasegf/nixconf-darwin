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

    plugins =
      let
        # Build all vim plugins from flake inputs with "vimPlugins_" prefix
        customPlugins = import ../lib/mkFlake2VimPlugin.nix inputs pkgs;

        keymapConfig = pkgs.vimUtils.buildVimPlugin {
          name = "keymap-config";
          src = ../config/nvim/keymapconfig;
        };

        config = pkgs.vimUtils.buildVimPlugin {
          name = "config";
          src = ../config/nvim/config;
        };

      in
      with pkgs.vimPlugins;
      [
        # ============================================
        # CORE PLUGINS - Load immediately at startup
        # ============================================

        # lz.n - lazy loading plugin (must load first to setup lazy loading)
        {
          plugin = customPlugins.lz-n;
          type = "lua";
          config = builtins.readFile ../config/nvim/lazy.lua;
        }

        # Base config
        {
          plugin = config;
          type = "lua";
          config = builtins.readFile ../config/nvim/config.lua;
        }

        # Theme - needs to load early for colors
        {
          plugin = dracula-vim;
          type = "lua";
          config = builtins.readFile ../config/nvim/color.lua;
        }

        # Keymap - essential keybindings (non-plugin-specific)
        {
          plugin = keymapConfig;
          type = "lua";
          config = builtins.readFile ../config/nvim/keymap.lua;
        }

        # Sops - automatic encryption/decryption
        {
          plugin = customPlugins.nvim-sops;
          type = "lua";
          config = builtins.readFile ../config/nvim/sops.lua;
        }

        # LSP & Completion - core functionality, load eagerly
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = builtins.readFile ../config/nvim/lsp.lua;
        }
        cmp-nvim-lsp
        cmp-buffer
        nvim-cmp
        luasnip
        lspkind-nvim
        none-ls-nvim
        nvim-jdtls
        neoconf-nvim

        {
          plugin = customPlugins.lsp-inlayhints;
          type = "lua";
        }

        # Treesitter - essential for syntax highlighting, load eagerly
        {
          plugin = (
            nvim-treesitter.withPlugins (
              _:
              nvim-treesitter.allGrammars
              ++ [
                nvim-treesitter-parsers.wgsl
                nvim-treesitter-parsers.astro
              ]
            )
          );
          type = "lua";
          config = builtins.readFile ../config/nvim/treesitter.lua;
        }

        # Statusline & Bufferline - visible UI elements, load eagerly
        {
          plugin = lualine-nvim;
          type = "lua";
          config = builtins.readFile ../config/nvim/lualine.lua;
        }
        {
          plugin = bufferline-nvim;
          type = "lua";
          config = builtins.readFile ../config/nvim/bufferline.lua;
        }

        # Autopairs - needed for typing immediately
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = builtins.readFile ../config/nvim/autopairs.lua;
        }

        # Autosave - needs to work from start
        {
          plugin = auto-save-nvim;
          type = "lua";
          config = builtins.readFile ../config/nvim/autosave.lua;
        }

        # ============================================
        # LAZY LOADED PLUGINS - Installed here, loaded by lz.n
        # No config here - lz.n handles setup in lazy.lua
        # ============================================

        # File tree
        nvim-tree-lua
        nvim-web-devicons

        # Telescope
        telescope-nvim

        # Git
        gitsigns-nvim
        octo-nvim
        vim-fugitive
        customPlugins.blamer

        # Debugger
        nvim-dap
        nvim-dap-ui
        nvim-dap-virtual-text
        telescope-dap-nvim
        nvim-dap-go

        # Terminal
        toggleterm-nvim

        # Database
        vim-dadbod
        vim-dadbod-ui
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

        # Markdown
        markdown-preview-nvim

        # Trouble
        trouble-nvim

        # Search/Replace
        nvim-spectre

        # Refactoring
        refactoring-nvim

        # Todo comments
        todo-comments-nvim

        # Motion
        flash-nvim
        harpoon

        # UI enhancements
        noice-nvim
        nvim-notify
        dressing-nvim
        nui-nvim

        # Smooth scrolling
        neoscroll-nvim

        # Folding
        promise-async
        nvim-ufo

        # Colorizer
        nvim-colorizer-lua

        # Indentation
        indent-blankline-nvim
        rainbow-delimiters-nvim

        # Comment
        comment-nvim
        nvim-ts-context-commentstring

        # Surround
        nvim-surround

        # Maximizer
        customPlugins.vim-maximizer

        # Registers
        registers-nvim

        # Session
        auto-session

        # Local config
        nvim-config-local

        # ============================================
        # OTHER PLUGINS - Language specific or misc
        # ============================================

        # Language specific
        {
          plugin = customPlugins.rainbow-csv;
        }
        {
          plugin = customPlugins.mdx;
          type = "lua";
          config = builtins.readFile ../config/nvim/mdx.lua;
        }

        vim-android
        otter-nvim
        nvim-ts-autotag
        vim-move
        vim-visual-multi

        {
          plugin = customPlugins.opencode;
          type = "lua";
          config = builtins.readFile ../config/nvim/opencode.lua;
        }

        {
          plugin = customPlugins.twoslash-queries;
          type = "lua";
        }

        # Misc utilities (dependencies)
        popup-nvim
        plenary-nvim
        vim-suda
      ];
  };
}
