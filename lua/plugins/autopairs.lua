local M = {}

M.packer = {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    require("plugins.autopairs").setup()
  end,
  -- disable = true,
}

M.config = {
  ---@usage  modifies the function or method delimiter by filetypes
  map_char = {
    all = "(",
    tex = "{",
  },
  ---@usage check bracket in same line
  enable_check_bracket_line = false,
  ---@usage check treesitter
  check_ts = true,
  ts_config = {
    lua = { "string", "source" },
    javascript = { "string", "template_string" },
    java = false,
  },
  disable_filetype = { "TelescopePrompt", "spectre_panel" },
  ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
  enable_moveright = true,
  ---@usage disable when recording or executing a macro
  disable_in_macro = true,
  ---@usage add bracket pairs after quote
  enable_afterquote = true,
  ---@usage map the <BS> key
  map_bs = true,
  ---@usage map <c-w> to delete a pair if possible
  map_c_w = true,
  ---@usage disable when insert after visual block mode
  disable_in_visualblock = true,
  ---@usage  change default fast_wrap
  fast_wrap = {
    map = "<M-e>",
    chars = { "{", "[", "(", '"', "'" },
    pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
    offset = 0, -- Offset from pattern match
    end_key = "$",
    keys = "qwertyuiopzxcvbnmasdfghjkl",
    check_comma = true,
    highlight = "Search",
    highlight_grey = "Comment",
  },
}

M.setup = function()
  local autopairs = require("nvim-autopairs")
  autopairs.setup(M.config)

  require("nvim-treesitter.configs").setup({ autopairs = { enable = true } })
end

return M
