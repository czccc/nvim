local M = {}

-- local path = require("utils.path")

M.config = {
  setup = {
    debounce = 150,
    save_after_format = true,
    on_attach = require("plugins.lsp").common_on_attach,
    capabilities = require("plugins.lsp").common_capabilities(),
    sources = {},
  },
}

function M.setup()
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    return
  end
  if vim.fn.executable("stylua") == 1 then
    table.insert(M.config.setup.sources, null_ls.builtins.formatting.stylua)
  end
  if vim.fn.executable("luacheck") == 1 then
    table.insert(M.config.setup.sources, null_ls.builtins.formatting.luacheck)
  end
  if vim.fn.executable("markdownlint") == 1 then
    table.insert(
      M.config.setup.sources,
      null_ls.builtins.diagnostics.markdownlint.with({
        -- extra_args = { "--config", path.join(path.config_dir, "markdownlint.json") },
        filetypes = { "markdown" },
      })
    )
  end
  if vim.fn.executable("prettierd") == 1 then
    table.insert(M.config.setup.sources, null_ls.builtins.formatting.prettierd)
  end
  if vim.fn.executable("black") == 1 then
    table.insert(M.config.setup.sources, null_ls.builtins.formatting.black)
  end

  null_ls.setup(M.config.setup)
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
