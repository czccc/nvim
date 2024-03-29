local M = {}

M.packer = {
  "akinsho/toggleterm.nvim",
  event = "BufWinEnter",
  config = function()
    require("plugins.toggleterm").setup()
  end,
  disable = false,
}

M.setup = function()
  local status_ok, terminal = pcall(require, "toggleterm")
  if not status_ok then
    return
  end

  terminal.setup({
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
  })

  utils.load_wk({
    name = "Terminal",
    t = { wrap(M.toggle), "Float" },
    -- h = { wrap(M.toggle, { nil, nil, "horizontal" }), "Horizontal" },
    -- v = { wrap(M.toggle, { nil, nil, "vertical" }), "Vertical" },
    g = { wrap(M.toggle, { "lazygit" }), "Lazygit" },
    G = { wrap(M.toggle, { "gitui" }), "Git UI" },
    H = { wrap(M.toggle, { "htop" }), "Htop" },
  }, { prefix = "<Leader>t", mode = "n" })
  utils.load_wk({
    name = "Git",
    g = { wrap(M.toggle, { "lazygit" }), "Lazygit" },
    G = { wrap(M.toggle, { "gitui" }), "Git UI" },
  }, { prefix = "<Leader>g", mode = "n" })
end

M.toggle = function(opts)
  opts = opts or {}
  local cmd = opts.cmd or opts[1]
  local cwd = opts.cwd or opts[2] or vim.fn.getcwd()
  local dir = opts.dir or opts[3] or "float"
  if opts.cmd then
    local binary = opts.cmd:match("(%S+)")
    if vim.fn.executable(binary) ~= 1 then
      vim.notify("Unknown cmd: " .. binary .. ". Please make sure it is installed properly.", vim.log.levels.INFO)
      return
    end
  end
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    cmd = cmd,
    dir = cwd,
    hidden = true,
    direction = dir,
  })
  term:toggle()
end

return M
