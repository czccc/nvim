local M = {}

M.lang_files = {
  "plugins.lsp.lang.clangd",
  "plugins.lsp.lang.go",
  "plugins.lsp.lang.json",
  "plugins.lsp.lang.lua",
  "plugins.lsp.lang.markdown",
  "plugins.lsp.lang.rust",
  "plugins.lsp.lang.yaml",
}

M.packers = require("plugins").merge(M.lang_files)

M.setup = function()
  for _, file in ipairs(M.lang_files) do
    local status, lang = pcall(require, file)
    if status and lang.lsp_setup then
      lang.lsp_setup()
    end
  end
  require("lspconfig")["pyright"].setup({})
end

return M
