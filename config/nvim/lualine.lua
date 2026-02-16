-- lualine statusline
return {
  "lualine.nvim",
  priority = 600,
  after = function()
    require("lualine").setup({
      options = {
        globalstatus = true,
      },
    })
  end,
}
