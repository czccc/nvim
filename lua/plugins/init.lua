local M = {}

local plugin_files = {
  "plugins.which_key",
  "plugins.misc",
  "plugins.notify",
  "plugins.hop",
  "plugins.lightspeed",

  "plugins.themes",

  "plugins.neotree",
  "plugins.bufferline",
  "plugins.git",
  "plugins.lualine",
  "plugins.autopairs",
  "plugins.wilder",
  "plugins.alpha",

  "plugins.telescope",
  "plugins.treesitter",
  "plugins.cmp",
  "plugins.comment",

  "plugins.tmux",
  "plugins.toggleterm",
  "plugins.async",
  "plugins.test",
  "plugins.session",

  "plugins.lsp",
  "plugins.dap",
  "plugins.lang",

  "plugins.hlslens",
  "plugins.harpoon",
  "plugins.indent_blankline",
  "plugins.lsp_signature",
  "plugins.neorg",
  "plugins.sidebar",
  "plugins.spectre",
  "plugins.todo",
}

M.packers = {}

M.init = function()
  M.packers = {}
  for _, plugin_file in ipairs(plugin_files) do
    local status_ok, plugin = pcall(require, plugin_file)
    if not status_ok then
      vim.notify("Unable to require file " .. plugin, "ERROR")
    end
    if plugin.init then
      pcall(plugin.init)
    end
    if plugin.packer then
      M.packers[#M.packers + 1] = plugin.packer
    end
    if plugin.packers then
      for _, plugin_packer in ipairs(plugin.packers) do
        M.packers[#M.packers + 1] = plugin_packer
      end
    end
  end
end

M.reload = function()
  M.packers = {}
  for _, plugin_file in ipairs(plugin_files) do
    local status_ok, plugin = pcall(require_clean, plugin_file)
    if not status_ok then
      vim.notify("Unable to require file " .. plugin, "ERROR")
    end
    if plugin.init then
      pcall(plugin.init)
    end
    if plugin.packer then
      M.packers[#M.packers + 1] = plugin.packer
    end
    if plugin.packers then
      for _, plugin_packer in ipairs(plugin.packers) do
        M.packers[#M.packers + 1] = plugin_packer
      end
    end
  end
end

return M
