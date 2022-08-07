local M = {}

M.packer = {
  "SmiteshP/nvim-navic",
  requires = "neovim/nvim-lspconfig",
  config = function()
    require("plugins.navic").setup()
  end,
  event = "BufRead",
  opt = true,
}

M.setup = function()
  local navic = require("nvim-navic")
  navic.setup({
    icons = {
      File = " ",
      Module = " ",
      Namespace = " ",
      Package = " ",
      Class = " ",
      Method = " ",
      Property = " ",
      Field = " ",
      Constructor = " ",
      Enum = "練",
      Interface = "練",
      Function = " ",
      Variable = " ",
      Constant = " ",
      String = " ",
      Number = " ",
      Boolean = "◩ ",
      Array = " ",
      Object = " ",
      Key = " ",
      Null = "ﳠ ",
      EnumMember = " ",
      Struct = " ",
      Event = " ",
      Operator = " ",
      TypeParameter = " ",
    },
    highlight = false,
    separator = " > ",
    depth_limit = 5,
    depth_limit_indicator = "..",
  })
end

return M
