local M = {}

M.packer = {
  "phaazon/hop.nvim",
  event = "BufRead",
  -- cmd = { "HopChar2", "HopWord" },
  config = function()
    require("plugins.hop").setup()
  end,
  disable = false,
}

M.setup = function()
  local hop = require("hop")
  local hint = require("hop.hint")
  hop.setup({
    keys = "etovxqpdygfblzhckisuran",
    jump_on_sole_occurrence = true,
    create_hl_autocmd = false,
  })

  local Key = require("utils.key").Key
  require("utils.key").load({
    Key({ "n", "v", "x" }, "f", function()
      hop.hint_char1({
        direction = hint.HintDirection.AFTER_CURSOR,
        current_line_only = true,
      })
    end, "Forward To"),
    Key({ "n", "v", "x" }, "F", function()
      hop.hint_char1({
        direction = hint.HintDirection.BEFORE_CURSOR,
        current_line_only = true,
      })
    end, "Backward To"),
    Key("o", "f", function()
      hop.hint_char1({
        direction = hint.HintDirection.AFTER_CURSOR,
        current_line_only = true,
        inclusive_jump = true,
      })
    end, "Forward To"),
    Key("o", "F", function()
      hop.hint_char1({
        direction = hint.HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        inclusive_jump = true,
      })
    end, "Backward To"),
    Key({ "n", "v", "x", "o" }, "t", function()
      hop.hint_char1({
        direction = hint.HintDirection.AFTER_CURSOR,
        current_line_only = true,
      })
    end, "Forward Till"),
    Key({ "n", "v", "x", "o" }, "T", function()
      hop.hint_char1({
        direction = hint.HintDirection.BEFORE_CURSOR,
        current_line_only = true,
      })
    end, "Backward Till"),
    Key({ "n" }, "<C-z>", "<cmd>HopWordMW<cr>", "HopWord MW"),
    Key({ "v", "x", "o" }, "<C-z>", "<cmd>HopWord<cr>", "HopWord"),
    Key("n", "<Leader>j"):group("Hop"),
    Key("n", "<Leader>jj", "<cmd>HopWordMW<cr>", "HopWord MW"),
    Key("n", "<Leader>jw", "<cmd>HopWord<cr>", "HopWord"),
    Key("n", "<Leader>jW", "<cmd>HopWordMW<cr>", "HopWord MW"),
    Key("n", "<Leader>jp", "<cmd>HopPattern<cr>", "HopPattern"),
    Key("n", "<Leader>jP", "<cmd>HopPatternMW<cr>", "HopPattern MW"),
    Key("n", "<Leader>jC", "<cmd>HopChar2<cr>", "HopChar2"),
    Key("n", "<Leader>jc", "<cmd>HopChar1<cr>", "HopChar1"),
    Key("n", "<Leader>jl", "<cmd>HopLine<cr>", "HopLine"),
    Key("n", "<Leader>jL", "<cmd>HopLineStart<cr>", "HopLineStart"),

    Key({ "v", "x" }, "<Leader>w", "<cmd>HopWord<cr>", "HopWord"),
    Key({ "v", "x" }, "<Leader>p", "<cmd>HopPattern<cr>", "HopPattern"),
    Key({ "v", "x" }, "<Leader>l", "<cmd>HopLine<cr>", "HopLine"),
    Key({ "v", "x" }, "<Leader>L", "<cmd>HopLineStart<cr>", "HopLineStart"),
    Key({ "v", "x" }, "<Leader>c", "<cmd>HopChar1<cr>", "HopChar1"),
    Key({ "v", "x" }, "<Leader>C", "<cmd>HopChar2<cr>", "HopChar2"),
  })
  -- vim.cmd([[highlight HopNextKey gui=bold guifg=Orange]])
  local cl = require("core.colors")
  cl.define_links("HopNextKey", "IncSearch")
  cl.define_links("HopNextKey1", "WildMenu")
  cl.define_links("HopNextKey2", "WarningMsg")
  cl.define_links("HopUnmatched", "NonText")
  cl.define_links("HopCursor", "Cursor")
  -- cl.define_styles("HopNextKey", { gui = "bold", guibg = "Orange", guifg = "Black" })
  -- cl.define_styles("HopNextKey1", { gui = "bold", guibg = "Blue", guifg = "Black" })
end

return M
