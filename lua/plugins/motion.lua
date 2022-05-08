local M = {}

M.packers = {
  {
    "ggandor/lightspeed.nvim",
    config = function()
      require("plugins.motion").setup_lightspeed()
    end,
    -- disable = true,
  },
  {
    "phaazon/hop.nvim",
    event = "BufRead",
    -- cmd = { "HopChar2", "HopWord" },
    config = function()
      require("plugins.motion").setup_hop()
    end,
    -- disable = true,
  },
}

M.setup_lightspeed = function()
  require("lightspeed").setup({
    ignore_case = true,
    --- f/t ---
    limit_ft_matches = 4,
    repeat_ft_with_target_char = false,
  })
end

M.setup_hop = function()
  local hop = require("hop")
  -- local hint = require("hop.hint")
  hop.setup({
    keys = "etovxqpdygfblzhckisuran",
    jump_on_sole_occurrence = true,
    create_hl_autocmd = false,
  })

  local Key = utils.Key
  utils.load({
    -- Key("n", "s", "<cmd>HopChar2MW<cr>", "HopChar2"),
    -- Key({ "v", "x", "o" }, "s", "<cmd>HopChar2<cr>", "HopChar2"),
    Key({ "n" }, "<Leader>w", "<cmd>HopWord<cr>", "HopWord"),
    Key({ "n" }, "<Leader>W", "<cmd>HopWordMW<cr>", "HopWord MW"),
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
end

return M
