local M = {}

M.packer = {
  "lukas-reineke/indent-blankline.nvim",
  setup = function()
    vim.g.indent_blankline_char = "▏"
  end,
  config = function()
    require("plugins.indent_blankline").setup()
  end,
  event = "BufReadPre",
  cmd = { "IndentBlanklineRefresh" },
}

M.config = {
  enabled = true,
  bufname_exclude = { "README.md" },
  buftype_exclude = { "terminal", "nofile" },
  filetype_exclude = {
    "alpha",
    "log",
    "gitcommit",
    "dapui_scopes",
    "dapui_stacks",
    "dapui_watches",
    "dapui_breakpoints",
    "dapui_hover",
    "LuaTree",
    "dbui",
    "UltestSummary",
    "UltestOutput",
    "vimwiki",
    "markdown",
    "json",
    "txt",
    "vista",
    "NvimTree",
    "git",
    "TelescopePrompt",
    "undotree",
    "flutterToolsOutline",
    "org",
    "orgagenda",
    "help",
    "startify",
    "dashboard",
    "packer",
    "neogitstatus",
    "NvimTree",
    "Outline",
    "Trouble",
    "lspinfo",
    "", -- for all buffers without a file type
  },
  char = "▏",
  -- char_list = { "", "┊", "┆", "¦", "|", "¦", "┆", "┊", "" },
  -- char_highlight_list = {
  --   "IndentBlanklineIndent1",
  -- },
  -- show_end_of_line = false,
  show_trailing_blankline_indent = false,
  show_first_indent_level = true,
  space_char_blankline = " ",
  use_treesitter = false,
  show_foldtext = false,
  show_current_context = true,
  show_current_context_start = false,
  context_patterns = {
    "class",
    "return",
    "function",
    "method",
    "import",
    "^if",
    "^do",
    "^switch",
    "^while",
    "^for",
    "^object",
    "^table",
    "jsx_element",
    "block",
    "arguments",
    "if_statement",
    "else_clause",
    "try_statement",
    "catch_clause",
    "import_statement",
    "operation_type",
    "list_literal",
  },
}

M.setup = function()
  require("indent_blankline").setup(M.config)
  -- HACK: work-around for https://github.com/lukas-reineke/indent-blankline.nvim/issues/59
  vim.wo.colorcolumn = "99999"
  vim.g.indent_blankline_char = "▏"
  utils.Key("n", "[oi", "<cmd>IndentBlanklineEnable<CR>", "Indent Line")
  utils.Key("n", "]oi", "<cmd>IndentBlanklineDisable<CR>", "Indent Line")
  utils.Key("n", "yoi", "<cmd>IndentBlanklineToggle<CR>", "Indent Line")
  utils.Group("UserIndentBlanklineRefreash", { "CursorMoved", "*", "IndentBlanklineRefresh" })

  -- vim.cmd [[highlight IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]]
  -- vim.cmd [[highlight IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]]
  -- vim.cmd [[highlight IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]]
  -- vim.cmd [[highlight IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]]
  -- vim.cmd [[highlight IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]]
  -- vim.cmd [[highlight IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]]
end

return M
