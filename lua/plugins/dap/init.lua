local M = {}

M.packers = {
  -- Debugging
  {
    "mfussenegger/nvim-dap",
    -- event = "BufWinEnter",
    config = function()
      require("plugins.dap").setup()
    end,
    disable = false,
  },

  -- Debugger management
  {
    "Pocco81/DAPInstall.nvim",
    -- event = "BufWinEnter",
    -- event = "BufRead",
    config = function()
      require("plugins.dap").setup_dap_install()
    end,
    disable = false,
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("plugins.dap").setup_dapui()
    end,
    ft = { "python", "rust", "go" },
    event = "BufReadPost",
    requires = { "mfussenegger/nvim-dap" },
    disable = false,
  },
}

M.config = {
  breakpoint = {
    text = "",
    texthl = "LspDiagnosticsSignError",
    linehl = "",
    numhl = "",
  },
  breakpoint_rejected = {
    text = "",
    texthl = "LspDiagnosticsSignHint",
    linehl = "",
    numhl = "",
  },
  stopped = {
    text = "",
    texthl = "LspDiagnosticsSignInformation",
    linehl = "DiagnosticUnderlineInfo",
    numhl = "LspDiagnosticsSignInformation",
  },
}

M.setup = function()
  local dap = require("dap")

  vim.fn.sign_define("DapBreakpoint", M.config.breakpoint)
  vim.fn.sign_define("DapBreakpointRejected", M.config.breakpoint_rejected)
  vim.fn.sign_define("DapStopped", M.config.stopped)

  dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
  require("plugins.dap.config").setup()
  local Key = require("utils.key").Key
  require("utils.key").load({
    Key("n", "<Leader>d"):group("Debug"),
    Key("n", "<Leader>dt", dap.toggle_breakpoint, "Toggle Breakpoint"),
    Key("n", "<Leader>db", dap.step_back, "Step Back"),
    Key("n", "<Leader>dc", dap.continue, "Continue"),
    Key("n", "<Leader>dC", dap.run_to_cursor, "Run To Cursor"),
    Key("n", "<Leader>dd", dap.disconnect, "Disconnect"),
    Key("n", "<Leader>dg", dap.session, "Get Session"),
    Key("n", "<Leader>di", dap.step_into, "Step Into"),
    Key("n", "<Leader>ds", dap.step_over, "Step Over"),
    Key("n", "<Leader>do", dap.step_out, "Step Out"),
    Key("n", "<Leader>dp", dap.pause, "Pause"),
    Key("n", "<Leader>dr", dap.repl.toggle, "Toggle Repl"),
    Key("n", "<Leader>dq", dap.close, "Quit"),
  })
end

M.setup_dapui = function()
  require("dapui").setup({
    icons = { expanded = "▾", collapsed = "▸" },
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    sidebar = {
      -- You can change the order of elements in the sidebar
      elements = {
        -- Provide as ID strings or tables with "id" and "size" keys
        {
          id = "scopes",
          size = 0.25, -- Can be float or integer > 1
        },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 00.25 },
      },
      size = 40,
      position = "left", -- Can be "left", "right", "top", "bottom"
    },
    tray = {
      elements = { "repl" },
      size = 10,
      position = "bottom", -- Can be "left", "right", "top", "bottom"
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
  })
  local dap, dapui = require("dap"), require("dapui")
  local Key = require("utils.key").Key
  require("utils.key").load({
    Key("n", "<Leader>d"):group("Debug"),
    Key("n", "<Leader>de", dapui.eval, "Eval"),
    Key("n", "<Leader>du", dapui.toggle, "Toggle Dap UI"),
  })
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

M.setup_dap_install = function()
  local dap_install = require("dap-install")

  dap_install.setup({
    installation_path = vim.fn.stdpath("data") .. "/dapinstall/",
  })
end

return M
