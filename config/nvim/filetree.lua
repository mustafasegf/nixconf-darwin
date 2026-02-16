return {
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
}
