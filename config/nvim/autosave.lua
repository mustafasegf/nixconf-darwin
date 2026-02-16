-- auto-save
return {
  "auto-save.nvim",
  priority = 300,
  after = function()
    require("auto-save").setup({
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
      condition = function(buf)
        local fn = vim.fn
        local buftype = fn.getbufvar(buf, "&buftype")
        local filetype = fn.getbufvar(buf, "&filetype")
        local modifiable = fn.getbufvar(buf, "&modifiable")

        -- Don't save for special buffers
        if buftype ~= "" then
          return false
        end

        -- Don't save for non-modifiable buffers
        if modifiable ~= 1 then
          return false
        end

        -- Exclude certain filetypes
        local excluded_filetypes = {
          "gitcommit",
          "gitrebase",
          "NvimTree",
          "TelescopePrompt",
          "alpha",
          "dashboard",
          "lazygit",
          "neo-tree",
          "oil",
          "toggleterm",
        }

        for _, ft in ipairs(excluded_filetypes) do
          if filetype == ft then
            return false
          end
        end

        return true
      end,
      write_all_buffers = false,
      debounce_delay = 1000,
      debug = false,
    })
  end,
}
