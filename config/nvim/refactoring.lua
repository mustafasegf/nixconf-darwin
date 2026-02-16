return {
  "refactoring.nvim",
  keys = {
    { "<leader>re", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "Extract function" },
    { "<leader>rf", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "Extract function to file" },
    { "<leader>rv", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "Extract variable" },
    { "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "Inline variable" },
    { "<leader>rb", function() require("refactoring").refactor("Extract Block") end, desc = "Extract block" },
    { "<leader>rbf", function() require("refactoring").refactor("Extract Block To File") end, desc = "Extract block to file" },
  },
  after = function()
    require("refactoring").setup()
  end,
}
