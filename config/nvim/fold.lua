return {
  "nvim-ufo",
  event = { "BufReadPost", "BufNewFile" },
  after = function()
    require("ufo").setup({
      provider_selector = function(_, _, buftype)
        if buftype ~= "" then
          return ""
        end

        return { "treesitter", "indent" }
      end,
    })

    vim.keymap.set("n", "zR", require("ufo").openAllFolds)
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
  end,
}
