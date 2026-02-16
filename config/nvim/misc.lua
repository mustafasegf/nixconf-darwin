return {
  {
    "vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },
  {
    "markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
  },
  {
    "trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    after = function()
      require("trouble").setup()
    end,
  },
}
