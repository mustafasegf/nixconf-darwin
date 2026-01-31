-- MDX configuration
-- Register MDX filetype to use markdown treesitter parser
-- This enables proper syntax highlighting for MDX files including code blocks

vim.treesitter.language.register('markdown', 'mdx')
