-- MDX filetype support
return {
  "mdx",
  priority = 100,
  after = function()
    vim.treesitter.language.register("markdown", "mdx")

    -- Ensure treesitter highlighting is attached to MDX buffers
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "mdx",
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
