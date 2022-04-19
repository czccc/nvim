local M = {}
M.packers = {
  {
    "simrat39/symbols-outline.nvim",
    setup = function()
      require("plugins.sidebar").setup_symbol()
    end,
    -- event = "BufRead",
    cmd = { "SymbolsOutline", "SymbolsOutlineClose" },
    disable = false,
  },
  {
    "sidebar-nvim/sidebar.nvim",
    config = function()
      require("plugins.sidebar").setup_sidebar()
    end,
    -- event = "BufRead",
    cmd = { "SidebarNvimToggle", "SidebarNvimClose" },
    disable = true,
  },
}

M.config_symbol = {
  highlight_hovered_item = true,
  show_guides = true,
  auto_preview = false,
  position = "right",
  relative_width = true,
  width = 12,
  show_numbers = false,
  show_relative_numbers = false,
  show_symbol_details = true,
  preview_bg_highlight = "Pmenu",
  keymaps = { -- These keymaps can be a string or a table for multiple keys
    close = { "<Esc>", "q" },
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "r",
    code_actions = "a",
  },
  lsp_blacklist = {},
  symbol_blacklist = {},
}

M.config_sidebar = {
  disable_default_keybindings = 0,
  bindings = {
    ["q"] = function()
      require("sidebar-nvim").close()
    end,
  },
  open = false,
  side = "right",
  initial_width = 30,
  hide_statusline = true,
  update_interval = 1000,
  sections = { "git", "diagnostics", "todos", "symbols" },
  section_separator = { "", "-----", "" },
  containers = {
    attach_shell = "/bin/sh",
    show_all = true,
    interval = 5000,
  },
  datetime = {
    icon = "",
    format = "%a %b %d, %H:%M",
    clocks = {
      { name = "local" },
    },
  },
  todos = {
    icon = "",
    ignored_paths = { "~" }, -- ignore certain paths, this will prevent huge folders like $HOME to hog Neovim with TODO searching
    initially_closed = false, -- whether the groups should be initially closed on start. You can manually open/close groups later.
  },
}

M.setup_symbol = function()
  -- require("symbols-outline")
  vim.g.symbols_outline = M.config_symbol
  vim.cmd([[ highlight! link FocusedSymbol Visual ]])
  local Key = require("utils.key").Key
  Key("n", "<Leader>vs", "<cmd>SymbolsOutline<cr>", "Symbols Outline"):set()
end

M.setup_sidebar = function()
  require("sidebar-nvim").setup(M.config_sidebar)
  local Key = require("utils.key").Key
  Key("n", "<Leader>vS", "<cmd>SidebarNvimToggle<cr>", "Sidebar"):set()
end

return M
