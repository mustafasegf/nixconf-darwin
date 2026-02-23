-- catppuccin mocha colorscheme + highlight overrides
return {
  "catppuccin-nvim",
  priority = 1000,
  after = function()
    require("catppuccin").setup({
      flavour = "mocha",
      transparent_background = true,
    })
    vim.cmd.colorscheme("catppuccin")
    vim.api.nvim_command("highlight WinBar guibg=#45475a")
    vim.api.nvim_command("highlight WinSeparator guifg=None")
    vim.api.nvim_command("highlight NvimTreeVertSplit guibg=None")
    vim.api.nvim_command("hi LspInlayHint guifg=#cdd6f4 guibg=#45475a")

    vim.api.nvim_command("highlight RainbowRed guifg=#f38ba8 ctermfg=Red")
    vim.api.nvim_command("highlight RainbowYellow guifg=#f9e2af ctermfg=Yellow")
    vim.api.nvim_command("highlight RainbowBlue guifg=#89b4fa ctermfg=Blue")
    vim.api.nvim_command("highlight RainbowGreen guifg=#a6e3a1 ctermfg=Green")
    vim.api.nvim_command("highlight RainbowViolet guifg=#cba6f7 ctermfg=Magenta")
    vim.api.nvim_command("highlight RainbowCyan guifg=#94e2d5 ctermfg=Cyan")
  end,
}
