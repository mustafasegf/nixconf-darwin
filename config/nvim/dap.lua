return {
  "nvim-dap",
  keys = {
    { "<F5>", function() require("dap").continue() end, desc = "DAP Continue" },
    { "<F3>", function() require("dap").step_over() end, desc = "DAP Step Over" },
    { "<F2>", function() require("dap").step_into() end, desc = "DAP Step Into" },
    { "<F4>", function() require("dap").step_out() end, desc = "DAP Step Out" },
    { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>B", function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, desc = "Conditional Breakpoint" },
    { "<leader>dm", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Log Point" },
    { "<leader>dr", function() require("dap").repl.open() end, desc = "DAP REPL" },
    { "<leader>do", function() require("dapui").toggle() end, desc = "DAP UI Toggle" },
  },
  after = function()
    vim.cmd("packadd nvim-dap-virtual-text")
    vim.cmd("packadd nvim-dap-ui")
    vim.cmd("packadd nvim-dap-go")
    vim.cmd("packadd telescope-dap.nvim")
    require("telescope").load_extension("dap")
    require("nvim-dap-virtual-text").setup()
    require("dap-go").setup()
    require("dapui").setup()

    local dap = require("dap")

    -- codelldb adapter path detection
    local extension_path = vim.env.HOME .. "/.vscode/extensions/vadimcn.vscode-lldb/"
    local codelldb_path = extension_path .. "adapter/codelldb"
    local liblldb_path = extension_path .. "lldb/lib/liblldb"
    local this_os = vim.loop.os_uname().sysname
    if this_os:find("Windows") then
      codelldb_path = extension_path .. "adapter\\codelldb.exe"
      liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
    else
      liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
    end

    dap.adapters.cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = vim.env.HOME .. "/.local/share/ccptools/extension/debugAdapters/bin/OpenDebugAD7",
    }
    dap.configurations.c = {
      {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtEntry = true,
        setupCommands = {{ text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = false }},
      },
      {
        name = "Attach to gdbserver :1234",
        type = "cppdbg",
        request = "launch",
        MIMode = "gdb",
        miDebuggerServerAddress = "localhost:1234",
        miDebuggerPath = "/usr/bin/gdb",
        cwd = "${workspaceFolder}",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        setupCommands = {{ text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = false }},
      },
    }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.rust = {
      {
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        terminal = "integrated",
        sourceLanguages = { "rust" },
      },
    }
  end,
}
