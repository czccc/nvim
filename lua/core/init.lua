local M = {}

M.load_core = function()
  pcall(require, "impatient")
  -- require("impatient").enable_profile()
  require("core.global")
  require("core.options").setup()
  require("core.keymap").setup()
  require("core.autocmds").setup()
end

M.load_plugins = function()
  require("core.pack").init()
  require("plugins").setup()
  require("core.osconf").setup()
  require("core.pack").setup()
end

M.reload = function()
  _G.packer_plugins = _G.packer_plugins or {}
  for k, v in pairs(_G.packer_plugins) do
    if k ~= "packer.nvim" then
      _G.packer_plugins[v] = nil
    end
  end
  for _, lua_file in ipairs(M.config_lua_list()) do
    package.loaded[lua_file] = nil
    _G[lua_file] = nil
  end

  require("core.global")
  require("core.options").setup()
  require("core.keymap").setup()
  require("core.autocmds").setup()

  require("core.pack").init()
  require("plugins").setup()
  require("core.osconf").setup()
  require("core.pack").setup()

  vim.notify("Reloaded", "INFO")
end

M.config_lua_list = function()
  local base_lua_dir = join_paths(utils.Path.config_dir, "lua")
  local lua_files = vim.fn.globpath(base_lua_dir, "**/*.lua", 0, 1)
  for i, lua_file in ipairs(lua_files) do
    lua_file = lua_file:gsub(base_lua_dir, "")
    lua_file = lua_file:sub(2, -5)
    lua_file = lua_file:gsub(utils.Path.separator, ".")
    lua_file = lua_file:gsub(".init", "")
    lua_files[i] = lua_file
  end
  return lua_files
end

return M
