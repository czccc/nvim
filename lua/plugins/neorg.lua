local M = {}

M.packer = {
  "nvim-neorg/neorg",
  ft = "norg",
  after = "nvim-treesitter", -- You may want to specify Telescope here as well
  config = function()
    require("plugins.neorg").setup()
  end,
}

M.setup = function()
  require("neorg").setup({
    load = {
      ["core.defaults"] = {},
    },
  })
end

return M
