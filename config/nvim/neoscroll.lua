return {
  "neoscroll.nvim",
  event = "UIEnter",
  after = function()
    require("neoscroll").setup({
      easing_function = "sine",
    })
  end,
}
