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
        # optional = true puts them in 'opt' packpath so lz.n controls loading
        # ============================================

        # File tree
        {
          plugin = nvim-tree-lua;
          optional = true;
        }
        nvim-web-devicons # dependency - keep eager for nvim-tree, telescope, etc.

        # Telescope
        {
          plugin = telescope-nvim;
          optional = true;
        }

        # Git
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
        customPlugins.blamer # loaded via gitsigns after hook

        # Debugger
        {
          plugin = nvim-dap;
          optional = true;
        }
        nvim-dap-ui # dependency - required by nvim-dap after hook
        nvim-dap-virtual-text # dependency - required by nvim-dap after hook
        telescope-dap-nvim # dependency - required by telescope after hook
        nvim-dap-go # dependency - required by nvim-dap after hook

        # Terminal
        {
          plugin = toggleterm-nvim;
          optional = true;
        }

        # Database
        vim-dadbod # dependency of vim-dadbod-ui
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

        # Markdown
        {
          plugin = markdown-preview-nvim;
          optional = true;
        }

        # Trouble
        {
          plugin = trouble-nvim;
          optional = true;
        }

        # Search/Replace
        {
          plugin = nvim-spectre;
          optional = true;
        }

        # Refactoring
        {
          plugin = refactoring-nvim;
          optional = true;
        }

        # Todo comments
        {
          plugin = todo-comments-nvim;
          optional = true;
        }

        # Motion
        {
          plugin = flash-nvim;
          optional = true;
        }
        {
          plugin = harpoon;
          optional = true;
        }

        # UI enhancements
        {
          plugin = noice-nvim;
          optional = true;
        }
        nvim-notify # dependency of noice
        dressing-nvim # dependency of noice/telescope
        nui-nvim # dependency of noice

        # Smooth scrolling
        {
          plugin = neoscroll-nvim;
          optional = true;
        }

        # Folding
        promise-async # dependency of nvim-ufo
        {
          plugin = nvim-ufo;
          optional = true;
        }

        # Colorizer
        {
          plugin = nvim-colorizer-lua;
          optional = true;
        }

        # Indentation
        {
          plugin = indent-blankline-nvim;
          optional = true;
        }
        rainbow-delimiters-nvim # dependency of indent-blankline

        # Comment
        {
          plugin = comment-nvim;
          optional = true;
        }
        nvim-ts-context-commentstring # dependency of Comment.nvim

        # Surround
        {
          plugin = nvim-surround;
          optional = true;
        }

        # Maximizer
        {
          plugin = customPlugins.vim-maximizer;
          optional = true;
        }

        # Registers
        {
          plugin = registers-nvim;
          optional = true;
        }

        # Session
        {
          plugin = auto-session;
          optional = true;
        }

        # Local config
        {
          plugin = nvim-config-local;
          optional = true;
        }

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
