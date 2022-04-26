local M = {}
local Log = require("core.log")

M.packer = {
  "akinsho/toggleterm.nvim",
  event = "BufWinEnter",
  config = function()
    require("plugins.toggleterm").setup()
  end,
  disable = false,
}

M.config = {
  setup = {
    -- size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = false,
    shading_factor = false, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = false,
    -- direction = 'vertical' | 'horizontal' | 'window' | 'float',
    direction = "float",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      -- The border key is *almost* the same as 'nvim_win_open'
      -- see :h nvim_win_open for details on borders however
      -- the 'curved' border is a custom border type
      -- not natively supported but implemented in this plugin.
      -- border = 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
      border = "curved",
      -- width = <value>,
      -- height = <value>,
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  },
  -- Add executables on the config.lua
  -- { exec, keymap, name, layout}
  execs = {
    ["<leader>tt"] = { "zsh", "<leader>tt", "Float", "float" },
    ["<leader>th"] = { "zsh", "<leader>th", "Horizontal", "horizontal" },
    ["<leader>tv"] = { "zsh", "<leader>tv", "Vertical", "vertical" },
    ["<leader>tg"] = { "lazygit", "<leader>tg", "LazyGit", "float" },
    ["<leader>tG"] = { "gitui", "<leader>tG", "Git UI", "float" },
    ["<leader>tp"] = { "python", "<leader>tp", "Python", "float" },
    ["<leader>tj"] = { "htop", "<leader>tj", "htop", "float" },
    ["<leader>tN"] = { "ncdu", "<leader>tN", "ncdu", "float" },
  },
}

M.setup = function()
  local status_ok, terminal = pcall(require, "toggleterm")
  if not status_ok then
    Log:warn("toggleterm not loaded")
    return
  end
  local config = M.config

  terminal.setup(config.setup)

  local c = 0
  for _, exec in pairs(config.execs) do
    c = c + 1
    local opts = {
      cmd = exec[1],
      keymap = exec[2],
      label = exec[3],
      -- NOTE: unable to consistently bind id/count <= 9, see #2146
      count = c + 100,
      direction = exec[4] or config.setup.direction,
    }
    M.add_exec(opts)
  end
end

M.add_exec = function(opts)
  local binary = opts.cmd:match("(%S+)")
  if vim.fn.executable(binary) ~= 1 then
    Log:debug("Skipping configuring executable " .. binary .. ". Please make sure it is installed properly.")
    return
  end

  local exec_func = string.format(
    "<cmd>lua require('plugins.toggleterm')._exec_toggle({ cmd = '%s', count = %d, direction = '%s' })<CR>",
    opts.cmd,
    opts.count,
    opts.direction
  )

  local Key = require("utils.key").Key
  require("utils.key").load({
    Key("n", opts.keymap, exec_func, opts.label),
  })
end

M._exec_toggle = function(opts)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    cmd = opts.cmd,
    hidden = true,
    count = opts.count,
    direction = opts.direction,
  })
  term:toggle()
end

return M
