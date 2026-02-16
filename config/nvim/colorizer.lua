return {
  "nvim-colorizer.lua",
  event = { "BufReadPost", "BufNewFile" },
  after = function()
    require("colorizer").setup()
  end,
}
