local M = {}

M.packer = require("plugins").merge({
  "plugins.lang.rust_tools",
  "plugins.lang.clangd_extension",
  "plugins.lang.markdown",
  "plugins.lang.go",
})

return M
