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
  hop.setup()

  local Key = require("utils.key").Key
  require("utils.key").load({
    Key("n", "f", function()
      hop.hint_char1({
        direction = hint.HintDirection.AFTER_CURSOR,
        current_line_only = true,
      })
    end, "Forward"),
    Key("n", "F", function()
      hop.hint_char1({
        direction = hint.HintDirection.BEFORE_CURSOR,
        current_line_only = true,
      })
    end, "Backward"),
    Key("o", "f", function()
      hop.hint_char1({
        direction = hint.HintDirection.AFTER_CURSOR,
        current_line_only = true,
        inclusive_jump = true,
      })
    end, "Forward"),
    Key("o", "F", function()
      hop.hint_char1({
        direction = hint.HintDirection.BEFORE_CURSOR,
        current_line_only = true,
        inclusive_jump = true,
      })
    end, "Backward"),
    Key("", "t", function()
      hop.hint_char1({
        direction = hint.HintDirection.AFTER_CURSOR,
        current_line_only = true,
      })
    end, "Forward Till"),
    Key("", "T", function()
      hop.hint_char1({
        direction = hint.HintDirection.BEFORE_CURSOR,
        current_line_only = true,
      })
    end, "Backward Till"),
    Key("n", "<Leader>j"):group("Hop"),
    Key("n", "<Leader>jw", "<cmd>HopWord<cr>", "HopWord"),
    Key("n", "<Leader>jp", "<cmd>HopPattern<cr>", "HopPattern"),
    Key("n", "<Leader>jc", "<cmd>HopChar2<cr>", "HopChar2"),
    Key("n", "<Leader>jC", "<cmd>HopChar1<cr>", "HopChar1"),
    Key("n", "<Leader>jl", "<cmd>HopLine<cr>", "HopLine"),
    Key("n", "<Leader>jL", "<cmd>HopLineStart<cr>", "HopLineStart"),
  })
  vim.cmd([[highlight HopNextKey gui=bold guifg=Orange]])
end

return M
