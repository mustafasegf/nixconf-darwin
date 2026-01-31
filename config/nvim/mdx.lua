-- MDX configuration
-- Register MDX filetype to use markdown treesitter parser
-- This enables proper syntax highlighting for MDX files including code blocks

vim.treesitter.language.register('markdown', 'mdx')

-- Ensure treesitter highlighting is attached to MDX buffers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "mdx",
  callback = function()
    vim.treesitter.start()
  end,
})
