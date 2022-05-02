local M = {}

M.packer = {
  "ggandor/lightspeed.nvim",
  config = function()
    require("plugins.lightspeed").setup()
  end,
}

M.setup = function()
  require("lightspeed").setup({
    ignore_case = true,
    --- f/t ---
    limit_ft_matches = 4,
    repeat_ft_with_target_char = false,
  })
end
return M
