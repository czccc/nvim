local M = {}

M.lsp_setup = function()
  local config = {
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
      },
    },
  }
  local common_config = {
    on_attach = require("plugins.lsp").common_on_attach,
    capabilities = require("plugins.lsp").common_capabilities(),
  }
  config = vim.tbl_deep_extend("force", common_config, config)
  require("lspconfig")["jsonls"].setup(config)
end

return M
