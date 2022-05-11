local M = {}

M.packer = require("plugins").merge({
  "plugins.lang.rust_tools",
  "plugins.lang.clangd_extension",
  "plugins.lang.markdown",
  "plugins.lang.go",

  "plugins.lang.sumneko_lua",
  "plugins.lang.jsonls",
  "plugins.lang.yamlls",
})

return M
