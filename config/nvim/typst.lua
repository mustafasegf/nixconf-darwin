return {
  "typst-preview.nvim",
  ft = "typst",
  keys = {
    { "<leader>tp", "<cmd>TypstPreviewToggle<cr>", desc = "Typst Preview Toggle" },
    { "<leader>tf", "<cmd>TypstPreviewFollowCursorToggle<cr>", desc = "Typst Preview Follow Cursor" },
  },
  after = function()
    require("typst-preview").setup({
      dependencies_bin = {
        ["tinymist"] = "tinymist",
        ["websocat"] = "websocat",
      },
    })
  end,
}
