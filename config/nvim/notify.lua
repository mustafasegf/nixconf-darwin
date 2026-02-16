-- nvim-notify
return {
  "nvim-notify",
  priority = 900,
  after = function()
    require("notify").setup({
      background_colour = "#000000",
    })
  end,
}
