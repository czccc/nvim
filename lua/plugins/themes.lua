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
  {
    "EdenEast/nightfox.nvim",
    -- opt = true,
    config = function()
      require("plugins.themes").setup_nightfox()
    end,
    -- disable = true,
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
  -- vim.g.onedark_disable_terminal_colors = true
  require("onedark").setup({
    -- Main options --
    style = "cool", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
    transparent = false, -- Show/hide background
    term_colors = false, -- Change terminal color as per the selected theme style
    ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
    cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
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
    colors = {
      bg0 = "#282c34",
    }, -- Override default colors
    highlights = {
      -- StatusLine = { bg = "$bg1" },
      SignColumn = { bg = "none" },
      -- StatusLineNC = { bg = "#2d3343" },
      -- Visual = { bg = "#404859" },
      Visual = { bg = "$bg3" },
      -- Search = { fg = "none", bg = "$bg3" },
      TSField = { fg = "$red" },
      TSOperator = { fg = "$purple" },
      TSVariable = { fg = "$red" },
      TSVariableBuiltin = { fg = "$yellow" },
      TSProperty = { fg = "$red" },
      TSFuncMacro = { fg = "$orange" },
      TSFuncBuiltin = { fg = "$orange" },
      TSConstant = { fg = "$orange" },
      packerStatusSuccess = { fg = "$green" },
      CmpItemAbbrMatch = { fg = "$green" },
      CmpItemAbbrMatchFuzzy = { fg = "$green" },
      OperatorSandwichChange = { fg = "$bg0", bg = "$orange" },
      OperatorSandwichDelete = { fg = "$bg0", bg = "$orange" },
      OperatorSandwichAdd = { fg = "$bg0", bg = "$orange" },
      HlSearchLens = { bg = "$bg3" },
      NeoTreeGitModified = { fg = "$yellow" },
      rainbowcol1 = { fg = "$purple" },
      HopNextKey = { fg = "$bg0", bg = "$orange", fmt = "none" },
      HopNextKey1 = { fg = "$bg0", bg = "$blue", fmt = "none" },
      HopNextKey2 = { fg = "$yellow", fmt = "bold" },
      HopUnmatched = { fg = "$grey" },
      LightspeedLabel = { fg = "$yellow", fmt = "bold,underline" },
      LightspeedShortcut = { fg = "$black", bg = "$blue", fmt = "bold" },
      LightspeedLabelDistant = { fg = "$blue", fmt = "bold,underline" },
      LightspeedUnlabeledMatch = { fg = "$black", bg = "$yellow", fmt = "bold" },
      LightspeedMaskedChar = { fg = "$purple", fmt = "bold" },
      LightspeedGreyWash = { fg = "$grey" },
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
  -- cl.define_links("Search", "Visual")
  cl.setup_colorscheme()
end

M.setup_nightfox = function()
  require("nightfox").setup({
    options = {
      -- Compiled file's destination location
      compile_path = vim.fn.stdpath("cache") .. "/nightfox",
      compile_file_suffix = "_compiled", -- Compiled file suffix
      transparent = false, -- Disable setting background
      terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
      dim_inactive = false, -- Non focused panes set to alternative background
      styles = { -- Style to be applied to different syntax groups

        comments = "italic",
        keywords = "bold",
        types = "italic,bold",
        functions = "NONE",
        numbers = "NONE",
        strings = "NONE",
        variables = "NONE",
      },
      inverse = { -- Inverse highlight for different types
        match_paren = false,
        visual = false,
        search = false,
      },
      modules = { -- List of various plugins and additional options
        -- ...
      },
    },
  })
end
return M
