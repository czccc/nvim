local M = {}

M.lsp_setup = function()
  local config = {
    settings = {
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
        schemas = {
          kubernetes = {
            "daemon.{yml,yaml}",
            "manager.{yml,yaml}",
            "restapi.{yml,yaml}",
            "role.{yml,yaml}",
            "role_binding.{yml,yaml}",
            "*onfigma*.{yml,yaml}",
            "*ngres*.{yml,yaml}",
            "*ecre*.{yml,yaml}",
            "*eployment*.{yml,yaml}",
            "*ervic*.{yml,yaml}",
            "kubectl-edit*.yaml",
          },
        },
      },
    },
  }
  local common_config = {
    on_attach = require("plugins.lsp").common_on_attach,
    capabilities = require("plugins.lsp").common_capabilities(),
  }
  config = vim.tbl_deep_extend("force", common_config, config)
  require("lspconfig")["yamlls"].setup(config)
end

return M
