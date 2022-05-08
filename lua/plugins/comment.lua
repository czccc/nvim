local M = {}

M.packer = {
  "numToStr/Comment.nvim",
  event = "BufRead",
  -- keys = { "gc", "gcc", "gbc" },
  config = function()
    require("plugins.comment").setup()
  end,
  disable = false,
}

M.config = {
  ---Add a space b/w comment and the line
  ---@type boolean
  padding = true,

  ---Lines to be ignored while comment/uncomment.
  ---Could be a regex string or a function that returns a regex string.
  ---Example: Use '^$' to ignore empty lines
  ---@type string|function
  ignore = "^$",

  ---LHS of line and block comment toggle mapping in NORMAL/VISUAL mode
  ---@type table
  toggler = {
    ---line-comment toggle
    line = "gcc",
    ---block-comment toggle
    block = "gbc",
  },

  ---LHS of line and block comment operator-mode mapping in NORMAL/VISUAL mode
  ---@type table
  opleader = {
    ---line-comment opfunc mapping
    line = "gc",
    ---block-comment opfunc mapping
    block = "gb",
  },
  ---LHS of extra mappings
  ---@type table
  extra = {
    ---Add comment on the line above
    above = "gcO",
    ---Add comment on the line below
    below = "gco",
    ---Add comment at the end of line
    eol = "gcA",
  },

  ---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
  ---NOTE: If `mappings = false` then the plugin won't create any mappings
  ---@type boolean|table
  mappings = {
    ---Operator-pending mapping
    ---Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
    ---NOTE: These mappings can be changed individually by `opleader` and `toggler` config
    basic = true,
    ---Extra mapping
    ---Includes `gco`, `gcO`, `gcA`
    extra = true,
    ---Extended mapping
    ---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
    extended = false,
  },

  ---Pre-hook, called before commenting the line
  ---@type function|nil
  pre_hook = function(ctx)
    local U = require("Comment.utils")

    -- Determine whether to use linewise or blockwise commentstring
    local type = ctx.ctype == U.ctype.line and "__default" or "__multiline"

    -- Determine the location where to calculate commentstring from
    local location = nil
    if ctx.ctype == U.ctype.block then
      location = require("ts_context_commentstring.utils").get_cursor_location()
    elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
      location = require("ts_context_commentstring.utils").get_visual_start_location()
    end

    return require("ts_context_commentstring.internal").calculate_commentstring({
      key = type,
      location = location,
    })
  end,

  ---Post-hook, called after commenting is done
  ---@type function|nil
  post_hook = nil,
}

M.setup = function()
  local nvim_comment = require("Comment")
  nvim_comment.setup(M.config)

  local api = require("Comment.api")
  local Key = utils.Key
  utils.load({
    Key("n", "gc"):group("Line Comment"),
    Key("n", "gcc"):desc("Line Comment"),
    Key("n", "gca"):desc("Line Comment (at EOL)"),
    Key("n", "gco"):desc("Add Comment Line Below"),
    Key("n", "gcO"):desc("Add Comment Line Above"),
    Key("x", "gc"):desc("Line Comment"),
    Key("n", "gb"):group("Block Comment"),
    Key("n", "gbc"):desc("Block Comment"),
    Key("x", "gb"):desc("Block Comment"),
    Key({ "n", "i" }, "<C-_>", api.toggle_current_linewise, "Line Comment"),
  })
end

return M
