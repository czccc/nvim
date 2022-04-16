local M = {}

M.init = function()
  require("core.colors").colorscheme = "onedark"
end

M.packers = {
  {
    "folke/tokyonight.nvim",
    config = function()
      require("plugins.themes").setup_tokyonight()
    end,
  },
  {
    "navarasu/onedark.nvim",
    -- opt = true,
    config = function()
      require("plugins.themes").setup_onedark()
    end,
  },
}

M.setup_tokyonight = function()
  vim.g.tokyonight_dev = true
  vim.g.tokyonight_style = "storm"
  vim.g.tokyonight_sidebars = {
    "qf",
    "vista_kind",
    "terminal",
    "packer",
    "spectre_panel",
    "NeogitStatus",
    "help",
    "Outline",
  }
  vim.g.tokyonight_cterm_colors = false
  vim.g.tokyonight_terminal_colors = true
  vim.g.tokyonight_italic_comments = true
  vim.g.tokyonight_italic_keywords = true
  vim.g.tokyonight_italic_functions = false
  vim.g.tokyonight_italic_variables = false
  vim.g.tokyonight_hide_inactive_statusline = true
  vim.g.tokyonight_dark_sidebar = true
  vim.g.tokyonight_dark_float = true
  vim.g.tokyonight_colors = {
    -- NvimTreeGitDirty = "orange",
    -- FocusedSymbol = "Visual",
  }
end

M.setup_onedark = function()
  vim.g.onedark_disable_terminal_colors = true
  require("onedark").setup({
    -- Main options --
    style = "cool", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = false, -- Show/hide background
    term_colors = true, -- Change terminal color as per the selected theme style
    ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
    -- toggle theme style ---
    toggle_style_key = "<NOP>", -- Default keybinding to toggle
    -- toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle between
    toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle between

    -- Change code style ---
    -- Options are italic, bold, underline, none
    -- You can configure multiple style with comma seperated, For e.g., keywords = 'italic,bold'
    code_style = {
      comments = "italic",
      keywords = "bold",
      functions = "none",
      strings = "none",
      variables = "none",
    },

    -- Custom Highlights --
    colors = {}, -- Override default colors
    highlights = {
      StatusLine = { bg = "$bg1" },
      SignColumn = { bg = "none" },
      -- StatusLineNC = { bg = "#2d3343" },
      Visual = { bg = "#404859" },
      -- Visual = { bg = "$bg3" },
      TSField = { fg = "$red" },
      TSOperator = { fg = "$purple" },
      TSVariable = { fg = "$red" },
      TSProperty = { fg = "$red" },
      TSFuncMacro = { fg = "$orange" },
      TSFuncBuiltin = { fg = "$orange" },
      TSConstant = { fg = "$orange" },
      packerStatusSuccess = { fg = "$green" },
    }, -- Override highlight groups

    -- Plugins Config --
    diagnostics = {
      darker = false, -- darker colors for diagnostic
      undercurl = true, -- use undercurl instead of underline for diagnostics
      background = false, -- use background color for virtual text
    },
  })
  -- require("onedark").load()
  local cl = require("core.colors")
  vim.g.terminal_color_8 = cl.colors.cool.grey
  cl.define_links("LspReferenceText", "Visual")
  cl.define_links("LspReferenceRead", "Visual")
  cl.define_links("LspReferenceWrite", "Visual")
  cl.define_links("FocusedSymbol", "Visual")
  cl.define_links("Search", "Visual")
  cl.define_links("OperatorSandwichChange", "IncSearch")
  cl.define_links("OperatorSandwichDelete", "IncSearch")
  cl.define_links("OperatorSandwichAdd", "IncSearch")
  cl.setup_colorscheme()
end

return M
