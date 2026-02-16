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

        # All config files live flat in config/nvim/
        # Nix copies them into lua/plugins/ so require("plugins.X") works
        configFiles = [
          # Eager configs (loaded on startup via require in lazy.lua)
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
          # Lazy plugin specs (loaded by lz.n)
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
        # ============================================
        # CORE PLUGINS - Load immediately at startup
        # ============================================

        # Config files (lua/plugins/*.lua) - must be on runtimepath before lz.n
        pluginSpecs

        # lz.n - lazy loading plugin (must load first to setup lazy loading)
        # lazy.lua is the only file loaded via builtins.readFile - it bootstraps everything else
        {
          plugin = customPlugins.lz-n;
          type = "lua";
          config = builtins.readFile ../config/nvim/lazy.lua;
        }

        # Theme
        dracula-vim

        # Sops
        customPlugins.nvim-sops

        # LSP
        nvim-lspconfig
        none-ls-nvim
        nvim-jdtls
        neoconf-nvim

        customPlugins.lsp-inlayhints

        # Treesitter
        (nvim-treesitter.withPlugins (
          _:
          nvim-treesitter.allGrammars
          ++ [
            nvim-treesitter-parsers.wgsl
            nvim-treesitter-parsers.astro
          ]
        ))

        # Statusline & Bufferline
        lualine-nvim
        bufferline-nvim

        # Autopairs
        nvim-autopairs

        # Autosave
        auto-save-nvim

        # ============================================
        # LAZY LOADED PLUGINS - Installed here, loaded by lz.n
        # No config here - lz.n handles setup in lazy.lua
        # optional = true puts them in 'opt' packpath so lz.n controls loading
        # ============================================

        # Completion
        {
          plugin = blink-cmp;
          optional = true;
        }

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
        {
          plugin = nvim-dap-ui; # dependency - required by nvim-dap after hook
          optional = true;
        }
        {
          plugin = nvim-dap-virtual-text; # dependency - required by nvim-dap after hook
          optional = true;
        }
        {
          plugin = telescope-dap-nvim; # dependency - required by telescope after hook
          optional = true;
        }
        {
          plugin = nvim-dap-go; # dependency - required by nvim-dap after hook
          optional = true;
        }

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
        customPlugins.mdx

        vim-android
        otter-nvim
        nvim-ts-autotag
        vim-move
        vim-visual-multi

        customPlugins.opencode
        customPlugins.twoslash-queries

        # Misc utilities (dependencies)
        popup-nvim
        plenary-nvim
        vim-suda
      ];
  };
}
