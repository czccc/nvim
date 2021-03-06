local M = {}

local path = require("utils.path")

M.config = {
  setup = {
    debounce = 150,
    save_after_format = true,
  },
}

function M.setup()
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    return
  end

  null_ls.setup({
    debounce = 150,
    save_after_format = true,
    on_attach = require("plugins.lsp").common_on_attach,
    capabilities = require("plugins.lsp").common_capabilities(),
    sources = {
      -- null_ls.builtins.completion.spell:with({
      --   filetypes = { "markdown" },
      -- }),

      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.black,

      null_ls.builtins.diagnostics.shellcheck,
      null_ls.builtins.diagnostics.luacheck,
      null_ls.builtins.diagnostics.vint,
      null_ls.builtins.diagnostics.markdownlint.with({
        extra_args = { "--config", path.join(path.config_dir, "markdownlint.json") },
        filetypes = { "markdown" },
      }),

      null_ls.builtins.code_actions.shellcheck,
      -- null_ls.builtins.code_actions.gitsigns,
    },
  })
end

function M.list_registered_providers_names(filetype)
  local s = require("null-ls.sources")
  local available_sources = s.get_available(filetype)
  local registered = {}
  for _, source in ipairs(available_sources) do
    for method in pairs(source.methods) do
      registered[method] = registered[method] or {}
      table.insert(registered[method], source.name)
    end
  end
  return registered
end

return M
