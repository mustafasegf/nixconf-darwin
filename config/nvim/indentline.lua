return {
  "indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile" },
  after = function()
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }
    require("ibl").setup({
      scope = { enabled = false },
      indent = { highlight = highlight },
    })
  end,
}
