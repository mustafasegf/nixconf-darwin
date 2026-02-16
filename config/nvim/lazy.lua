-- Neovim configuration entrypoint
-- All config files live flat in config/nvim/ and return lz.n spec tables.
-- Eager plugins use priority (no triggers), lazy plugins use event/cmd/ft/keys.

vim.g.mapleader = " "

-- Base vim settings (not plugin configs)
require("plugins.config")
require("plugins.keymap")

-- All plugin specs — eager (high priority, no triggers) and lazy (triggered)
local specs = {}
local plugins = {
  -- Eager: loaded immediately at startup, ordered by priority
  "color",       -- colorscheme (priority 1000)
  "notify",      -- nvim-notify (priority 900)
  "lsp",         -- LSP (priority 800)
  "treesitter",  -- syntax highlighting (priority 700)
  "lualine",     -- statusline (priority 600)
  "bufferline",  -- bufferline (priority 500, disabled)
  "autopairs",   -- auto pairs (priority 400)
  "autosave",    -- auto save (priority 300)
  "sops",        -- sops encryption (priority 200)
  "mdx",         -- MDX filetype (priority 100)
  "opencode",    -- opencode (priority 100)
  -- Lazy: loaded on demand by lz.n triggers
  "completion",
  "filetree",
  "telescope",
  "git",
  "dap",
  "toggleterm",
  "misc",
  "spectre",
  "refactoring",
  "todocomments",
  "flash",
  "harpoon",
  "noice",
  "neoscroll",
  "fold",
  "colorizer",
  "indentline",
  "editing",
  "session",
}

for _, mod in ipairs(plugins) do
  local spec = require("plugins." .. mod)
  if type(spec[1]) == "string" then
    specs[#specs + 1] = spec
  else
    for _, s in ipairs(spec) do
      specs[#specs + 1] = s
    end
  end
end

require("lz.n").load(specs)
