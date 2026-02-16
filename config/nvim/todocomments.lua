return {
  "todo-comments.nvim",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
  },
  after = function()
    require("todo-comments").setup()
  end,
}
