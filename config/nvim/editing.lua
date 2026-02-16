return {
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
}
