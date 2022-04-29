local M = {}

local lvim_lsp_utils = require("plugins.lsp.utils")

---Resolve the configuration for a server based on both common and user configuration
---@param name string
---@param user_config table [optional]
---@return table
local function resolve_config(name, user_config)
  local config = {
    on_attach = require("plugins.lsp").common_on_attach,
    on_init = require("plugins.lsp").common_on_init,
    on_exit = require("plugins.lsp").common_on_exit,
    capabilities = require("plugins.lsp").common_capabilities(),
  }

  local has_custom_provider, custom_config = pcall(require, "plugins/lsp/providers/" .. name)
  if has_custom_provider then
    config = vim.tbl_deep_extend("force", config, custom_config)
  end

  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end

  return config
end

-- manually start the server and don't wait for the usual filetype trigger from lspconfig
local function buf_try_add(server_name, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require("lspconfig")[server_name].manager.try_add_wrapper(bufnr)
end

-- check if the manager autocomd has already been configured since some servers can take a while to initialize
-- this helps guarding against a data-race condition where a server can get configured twice
-- which seems to occur only when attaching to single-files
local function client_is_configured(server_name, ft)
  ft = ft or vim.bo.filetype
  local active_autocmds = vim.split(vim.fn.execute("autocmd FileType " .. ft), "\n")
  for _, result in ipairs(active_autocmds) do
    if result:match(server_name) then
      return true
    end
  end
  return false
end

---Setup a language server by providing a name
---@param server_name string name of the language server
---@param user_config table [optional] when available it will take predence over any default configurations
function M.setup(server_name, user_config)
  vim.validate({ name = { server_name, "string" } })
  local lsp_config = require("plugins.lsp").config

  if lvim_lsp_utils.is_client_active(server_name) or client_is_configured(server_name) then
    vim.notify(string.format("[%q] is already configured. Ignoring repeated setup call.", server_name), "INFO")
    return
  end

  local config = resolve_config(server_name, user_config)

  local servers = require("nvim-lsp-installer.servers")
  local server_available, requested_server = servers.get_server(server_name)

  local is_overridden = vim.tbl_contains(lsp_config.override, server_name)

  if not server_available or is_overridden then
    pcall(function()
      require("lspconfig")[server_name].setup(config)
      buf_try_add(server_name)
    end)
    return
  end

  local install_notification = false

  if not requested_server:is_installed() then
    if lsp_config.automatic_servers_installation then
      requested_server:install()
      install_notification = true
    end
  end

  requested_server:on_ready(function()
    if install_notification then
      vim.notify(string.format("Installation complete for [%s] server", requested_server.name), vim.log.levels.INFO)
    end
    install_notification = false
    requested_server:setup(config)
  end)
end

return M
