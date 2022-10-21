local M = {}

M.packer = {
  "ojroques/vim-oscyank",
  config = function()
    require("plugins.oscyank").config()
  end,
}

M.init = function()
  vim.cmd([[
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif
  ]])
  vim.cmd([[ let g:oscyank_silent = v:true ]])
end

M.config = function() end

return M
