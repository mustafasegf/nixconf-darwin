return {
  "nvim-spectre",
  keys = {
    { "<leader>fr", function() require("spectre").open() end, desc = "Open Spectre" },
    { "<leader>fw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search current word" },
    { "<leader>fw", function() require("spectre").open_visual() end, mode = "v", desc = "Search selection" },
    { "<leader>fe", function() require("spectre").open_file_search() end, desc = "Search in file" },
  },
  cmd = "Spectre",
  after = function()
    require("spectre").setup()
  end,
}
