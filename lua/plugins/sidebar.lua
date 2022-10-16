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
    "mbbill/undotree",
    setup = function()
      require("plugins.sidebar").setup_undotree()
    end,
    cmd = { "UndotreeToggle" },
  },
}

M.setup_symbol = function()
  require("symbols-outline").setup({
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
  })
  vim.cmd([[ highlight! link FocusedSymbol Visual ]])
  utils.Key("n", "<Leader>us", "<cmd>SymbolsOutline<cr>", "Symbols Outline")
end

M.setup_undotree = function()
  vim.cmd([[ let g:undotree_WindowLayout = 3 ]])
  vim.cmd([[ let g:undotree_SetFocusWhenToggle = 1 ]])
  utils.Key("n", "<Leader>uu", "<cmd>UndotreeToggle<cr>", "Undo Tree")
end

return M
