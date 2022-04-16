local M = {}

local leader_map = function()
  -- vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "
  -- vim.api.nvim_set_keymap("n", " ", "", {noremap = true})
  -- vim.api.nvim_set_keymap("x", " ", "", {noremap = true})
end

M.load_core = function()
  pcall(require, "impatient")
  -- require("impatient").enable_profile()
  leader_map()
  require("core.global")
  require("core.options").setup()
  require("core.keymap").setup()
  require("core.autocmds").setup()
end

M.load_plugins = function()
  require("core.log"):init()
  require("core.pack").init()
  require("plugins").init()
  require("core.osconf").setup()
  require("core.pack").setup()
  require("core.colors").setup()
end

M.reload = function()
  _G.packer_plugins = _G.packer_plugins or {}
  for k, v in pairs(_G.packer_plugins) do
    if k ~= "packer.nvim" then
      _G.packer_plugins[v] = nil
    end
  end

  require("plugins").reload()
  require("core.osconf").setup()
  require("core.pack").setup()

  vim.notify("Reloaded")
end

return M
