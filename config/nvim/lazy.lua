-- lz.n lazy loading configuration
-- Plugins are installed by Nix, lz.n handles deferred loading
-- This file defines WHEN plugins load, configs are in separate files

-- Set mapleader BEFORE lz.n.load() so <leader> keymaps resolve correctly
vim.g.mapleader = " "

require("lz.n").load({
  -- ============================================
  -- FILE TREE - load on command/keymap
  -- ============================================
  {
    "nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile", "NvimTreeRefresh" },
    keys = {
      { "<leader>tt", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
      { "<leader>tr", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh NvimTree" },
      { "<leader>tn", "<cmd>NvimTreeFindFile<CR>", desc = "Find file in NvimTree" },
    },
    after = function()
      require("nvim-tree").setup({
        view = { side = "right", width = 40 },
        diagnostics = { enable = true, show_on_dirs = true },
      })
    end,
  },

  -- ============================================
  -- TELESCOPE - load on command/keymap
  -- ============================================
  {
    "telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fl", "<cmd>Telescope git_files<CR>", desc = "Git files" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope current_buffer_fuzzy_find fuzzy=false case_mode=ignore_case previewer=false<CR>", desc = "Fuzzy find in buffer" },
    },
    after = function()
      require("telescope").load_extension("dap")
    end,
  },

  -- ============================================
  -- GIT PLUGINS - load on events/commands
  -- ============================================
  {
    "gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        current_line_blame_opts = { virt_text = false, delay = 300 },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true })
          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true })
          map("n", "<leader>tb", gs.toggle_current_line_blame)
          map("n", "<leader>td", gs.toggle_deleted)
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
      vim.g.blamer_enabled = 1
    end,
  },
  {
    "vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gdiff", "Gvdiffsplit" },
  },
  {
    "octo.nvim",
    cmd = "Octo",
  },

  -- ============================================
  -- DEBUGGER - load on command/keymap
  -- ============================================
  {
    "nvim-dap",
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
      { "<F3>", function() require("dap").step_over() end, desc = "DAP Step Over" },
      { "<F2>", function() require("dap").step_into() end, desc = "DAP Step Into" },
      { "<F4>", function() require("dap").step_out() end, desc = "DAP Step Out" },
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>B", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP REPL" },
      { "<leader>do", function() require("dapui").toggle() end, desc = "DAP UI Toggle" },
    },
    after = function()
      require("nvim-dap-virtual-text").setup()
      require("dap-go").setup()
      require("dapui").setup()

      local dap = require("dap")
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = vim.env.HOME .. "/.local/share/ccptools/extension/debugAdapters/bin/OpenDebugAD7",
      }
      dap.configurations.c = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = true,
          setupCommands = {{ text = "-enable-pretty-printing", ignoreFailures = false }},
        },
      }
      dap.configurations.cpp = dap.configurations.c
      dap.configurations.rust = {
        {
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          terminal = "integrated",
          sourceLanguages = { "rust" },
        },
      }
    end,
  },

  -- ============================================
  -- TERMINAL - load on command/keymap
  -- ============================================
  {
    "toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    },
    after = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- ============================================
  -- DATABASE - load on command
  -- ============================================
  {
    "vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },

  -- ============================================
  -- MARKDOWN - load on filetype
  -- ============================================
  {
    "markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
  },

  -- ============================================
  -- TROUBLE DIAGNOSTICS - load on command
  -- ============================================
  {
    "trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    after = function()
      require("trouble").setup()
    end,
  },

  -- ============================================
  -- SEARCH/REPLACE - load on command/keymap
  -- ============================================
  {
    "nvim-spectre",
    keys = {
      { "<leader>S", function() require("spectre").toggle() end, desc = "Toggle Spectre" },
    },
    cmd = "Spectre",
    after = function()
      require("spectre").setup()
    end,
  },

  -- ============================================
  -- REFACTORING - load on command/keymap
  -- ============================================
  {
    "refactoring.nvim",
    keys = {
      { "<leader>re", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "Extract function" },
      { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "Extract variable" },
    },
    after = function()
      require("refactoring").setup()
    end,
  },

  -- ============================================
  -- TODO COMMENTS - load on buffer read
  -- ============================================
  {
    "todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      require("todo-comments").setup()
    end,
  },

  -- ============================================
  -- MOTION PLUGINS - load on keymap
  -- ============================================
  {
    "flash.nvim",
    keys = {
      { "s", function() require("flash").jump() end, mode = { "n", "x", "o" }, desc = "Flash" },
      { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash Treesitter" },
    },
  },
  {
    "harpoon",
    keys = {
      { "<leader>mm", function() require("harpoon.mark").add_file() end, desc = "Harpoon add file" },
      { "<leader>mf", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
      { "<leader>ml", function() require("harpoon.ui").nav_next() end, desc = "Harpoon next" },
      { "<leader>mh", function() require("harpoon.ui").nav_prev() end, desc = "Harpoon prev" },
    },
    after = function()
      require("harpoon").setup({ menu = { width = 100 } })
    end,
  },

  -- ============================================
  -- UI ENHANCEMENTS - load after startup
  -- ============================================
  {
    "noice.nvim",
    event = "UIEnter",
    after = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
        },
      })
    end,
  },
  {
    "neoscroll.nvim",
    event = "UIEnter",
    after = function()
      require("neoscroll").setup()
    end,
  },

  -- ============================================
  -- FOLDING - load on buffer read
  -- ============================================
  {
    "nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
    end,
  },

  -- ============================================
  -- VISUAL ENHANCEMENTS - load on buffer read
  -- ============================================
  {
    "nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      require("colorizer").setup()
    end,
  },
  {
    "indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    after = function()
      require("ibl").setup()
    end,
  },

  -- ============================================
  -- EDITING HELPERS - load on keymap
  -- ============================================
  {
    "Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    after = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "nvim-surround",
    keys = {
      { "ys", desc = "Add surround" },
      { "ds", desc = "Delete surround" },
      { "cs", desc = "Change surround" },
      { "S", mode = "v", desc = "Surround selection" },
    },
    after = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "vim-maximizer",
    cmd = "MaximizerToggle",
    keys = {
      { "<leader>z", "<cmd>MaximizerToggle<CR>", desc = "Maximize window" },
    },
  },
  {
    "registers.nvim",
    keys = {
      { '"', mode = { "n", "v" }, desc = "Show registers" },
      { "<C-r>", mode = "i", desc = "Show registers in insert" },
    },
    after = function()
      require("registers").setup()
    end,
  },

  -- ============================================
  -- SESSION - load on VimEnter
  -- ============================================
  {
    "auto-session",
    event = "VimEnter",
    after = function()
      require("auto-session").setup({
        log_level = "error",
        auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      })
    end,
  },

  -- ============================================
  -- LOCAL CONFIG - load on buffer read
  -- ============================================
  {
    "nvim-config-local",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("config-local").setup({
        config_files = { ".nvim.lua", ".nvimrc", ".exrc" },
        hashfile = vim.fn.stdpath("data") .. "/config-local",
        autocommands_create = true,
        commands_create = true,
        silent = false,
        lookup_parents = false,
      })
    end,
  },
})
