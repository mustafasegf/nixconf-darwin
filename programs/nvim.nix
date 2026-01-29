{ config, pkgs, libs, inputs, ... }: {

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = let
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

    in with pkgs.vimPlugins; [
      {
        plugin = config;
        type = "lua";
        config = builtins.readFile ../config/nvim/config.lua;
      }
      # theme
      {
        plugin = dracula-vim;
        type = "lua";
        config = builtins.readFile ../config/nvim/color.lua;
      }

      #keymap
      {
        plugin = keymapConfig;
        type = "lua";
        config = builtins.readFile ../config/nvim/keymap.lua;
      }

      #lsp
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
      markdown-preview-nvim
      nvim-jdtls

      {
        plugin = customPlugins.lsp-inlayhints;
        type = "lua";
      }

      # {
      #   plugin = (pluginGit "nanotee" "sqls.nvim" "main"
      #     "sha256-o5uD6shPkweuE+k/goBX42W3I2oojXVijfJC7L50sGU=");
      #   type = "lua";
      # }

      #language spesific
      # {
      #   plugin = (pluginGit "ray-x" "go.nvim" "master"
      #     "z65o3cOoxWILDKjEUWNTK1X7riQjxAS7BGeo29049Ms=");
      #   type = "lua";
      # }
      {
        plugin = customPlugins.rainbow-csv;
      }
      # {
      #   plugin = (pluginGit "kiyoon" "jupynium.nvim" "master"
      #     "HJrg+Jun4CxXKBgKEQGnF/EjyrXjJMwLexCCrnXA0+Y=");
      #   type = "lua";
      #   config = builtins.readFile ../config/nvim/jupyter.lua;
      # }
      dressing-nvim
      # rust-tools-nvim
      nvim-notify
      vim-android
      neoconf-nvim

      #file tree
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ../config/nvim/filetree.lua;
      }
      nvim-web-devicons

      # buffer
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/bufferline.lua;
      }
      {

        plugin = toggleterm-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/toggleterm.lua;
      }

      #cosmetic
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/indentline.lua;
      }
      rainbow-delimiters-nvim
      promise-async
      {
        plugin = nvim-ufo;
        type = "lua";
        config = builtins.readFile ../config/nvim/fold.lua;
      }

      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/lualine.lua;
      }
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''

          -- nvim-colorizer
          require("colorizer").setup()
        '';
      }
      {
        plugin = neoscroll-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/neoscroll.lua;
      }

      #git
      octo-nvim
      vim-fugitive
      {
        plugin = customPlugins.blamer;
        type = "lua";
      }
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/gitsigns.lua;
      }
      trouble-nvim

      #addon app
      vim-dadbod
      vim-dadbod-ui
      # vim-dadbod-completion
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

      otter-nvim

      #auto
      # cmp-tabnine
      # copilot-vim
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = builtins.readFile ../config/nvim/autopairs.lua;
      }

      #quality of life
      {
        plugin = comment-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/comment.lua;
      }
      { plugin = nvim-ts-context-commentstring; }
      nvim-ts-autotag
      vim-move
      vim-visual-multi
      {
        plugin = nvim-surround;
        type = "lua";
        config = ''
          require("nvim-surround").setup()
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/telescope.lua;
      }
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/todo-comments.lua;
      }
      {
        plugin = auto-save-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/autosave.lua;
      }
      {
        plugin = refactoring-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/refactoring.lua;
      }
      {
        plugin = nvim-spectre;
        type = "lua";
        config = builtins.readFile ../config/nvim/spectre.lua;
      }

      #session
      {
        plugin = auto-session;
        type = "lua";
        config = builtins.readFile ../config/nvim/session.lua;
      }

      #debugger
      {
        plugin = nvim-dap;
        type = "lua";
        config = builtins.readFile ../config/nvim/dap.lua;
      }
      nvim-dap-ui
      nvim-dap-virtual-text
      telescope-dap-nvim
      nvim-dap-go
      {
        plugin = customPlugins.vim-maximizer;
      }

      #misc
      popup-nvim
      plenary-nvim
      registers-nvim
      vim-suda
      nui-nvim
      # {
      #   plugin = (pluginGit "amitds1997" "remote-nvim.nvim" "main"
      #     "yU9eqb4YSSnJ/tgsqq/P/LQBz/yJCwbQJhPoqYBOlaY=");
      #   type = "lua";
      #   config = ''require("remote-nvim").setup()'';
      # }
      {
        plugin = harpoon;
        type = "lua";
        config = builtins.readFile ../config/nvim/harpoon.lua;
      }
      {
        plugin = flash-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/flash.lua;
      }
      {
        plugin = nvim-config-local;
        type = "lua";
        config = builtins.readFile ../config/nvim/local.lua;
      }
      {
        plugin = customPlugins.opencode;
        type = "lua";
        config = builtins.readFile ../config/nvim/opencode.lua;
      }

      {
        plugin = noice-nvim;
        type = "lua";
        config = builtins.readFile ../config/nvim/noice.lua;
      }
      {
        plugin = customPlugins.twoslash-queries;
        type = "lua";
      }

      # playground
      {
        plugin = (nvim-treesitter.withPlugins (_:
          nvim-treesitter.allGrammars ++ [
            nvim-treesitter-parsers.wgsl
            nvim-treesitter-parsers.astro

            # (pkgs.tree-sitter.buildGrammar
            #   {
            #     language = "wgsl";
            #     version = "40259f3";
            #     src = pkgs.fetchFromGitHub {
            #       owner = "szebniok";
            #       repo = "tree-sitter-wgsl";
            #       rev = "40259f3c77ea856841a4e0c4c807705f3e4a2b65";
            #       sha256 = "sha256-voLkcJ/062hzipb3Ak/mgQvFbrLUJdnXq1IupzjMJXA=";
            #     };
            #   })
            # (pkgs.tree-sitter.buildGrammar {
            #   language = "astro";
            #   version = "e122a8f";
            #   src = pkgs.fetchFromGitHub {
            #     owner = "virchau13";
            #     repo = "tree-sitter-astro";
            #     rev = "e122a8fcd07e808a7b873bfadc2667834067daf1";
            #     sha256 = "sha256-iCVRTX2fMW1g40rHcJEwwE+tfwun+reIaj5y4AFgmKk=";
            #   };
            # })
          ]));
        type = "lua";
        config = builtins.readFile ../config/nvim/treesitter.lua;
      }
      # (vim-wakatime.overrideAttrs (old: {
      #   patchPhase = ''
      #     # Move the BufEnter hook from the InitAndHandleActivity call
      #     # to the common HandleActivity call. This is necessary because
      #     # InitAndHandleActivity prompts the user for an API key if
      #     # one is not found, which breaks the remote plugin manifest
      #     # generation.
      #     substituteInPlace plugin/wakatime.vim \
      #       --replace 'autocmd BufEnter,VimEnter' \
      #                 'autocmd VimEnter' \
      #       --replace 'autocmd CursorMoved,CursorMovedI' \
      #                 'autocmd CursorMoved,CursorMovedI,BufEnter'
      #   '';
      #   configurePhase = ''
      #     export 
      #   '';
      # }))
    ];
  };
}
