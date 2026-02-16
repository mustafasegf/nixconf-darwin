return {
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
}
