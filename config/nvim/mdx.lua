-- MDX configuration
-- Enable syntax highlighting for code blocks in MDX files

-- Ensure MDX treesitter parser is enabled
require('nvim-treesitter.configs').setup({
  ensure_installed = {}, -- managed by Nix, not treesitter
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

-- Configure MDX to properly highlight embedded languages
vim.treesitter.language.register('markdown', 'mdx')
