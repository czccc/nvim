local M = {}

local plugin_files = {
  "plugins.which_key",
  "plugins.misc",
  "plugins.notify",
  "plugins.motion",

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
  -- "plugins.dap",
  "plugins.lang",

  "plugins.hlslens",
  "plugins.indent_blankline",
  "plugins.neorg",
  "plugins.sidebar",
  "plugins.spectre",
  "plugins.todo",
}

M.packers = {}

M.setup = function()
  M.packers = M.merge(plugin_files)
end

M.reload = function()
  M.packers = M.merge(plugin_files, true)
end

M.merge = function(file_list, clean)
  local merged = {}
  local require_fn = clean and require_clean or require
  for _, plugin_file in ipairs(file_list) do
    local status_ok, plugin = pcall(require_fn, plugin_file)
    if not status_ok then
      vim.notify("Unable to require file " .. plugin, "ERROR")
    end
    if plugin.init then
      pcall(plugin.init)
    end
    if plugin.packer then
      plugin.packers = { plugin.packer }
    end
    if plugin.packers then
      for _, plugin_packer in ipairs(plugin.packers) do
        if not plugin_packer.disable then
          merged[#merged + 1] = plugin_packer
        end
      end
    end
  end
  return merged
end

return M
