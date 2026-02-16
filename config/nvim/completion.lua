-- blink.cmp completion
return {
  "blink.cmp",
  event = "InsertEnter",
  after = function()
    require("blink.cmp").setup({
      keymap = {
        preset = "enter",
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        ghost_text = { enabled = true },
        list = { selection = { preselect = false, auto_insert = true } },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          sql = { "dadbod", "buffer" },
          mysql = { "dadbod", "buffer" },
          plsql = { "dadbod", "buffer" },
        },
        providers = {
          dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        },
      },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust" },
    })
  end,
}
