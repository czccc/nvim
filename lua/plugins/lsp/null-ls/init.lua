local M = {}

local Log = require "core.log"
local path = require "utils.path"

M.config = {
  setup = {
    debounce = 150,
    save_after_format = true,
  },
  config = {},
}

function M:setup()
  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    Log:error "Missing null-ls dependency"
    return
  end
  M.config.setup.sources = {
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.black,
    -- null_ls.builtins.formatting.isort.with { extra_args = { "--profile", "black" }, filetypes = { "python" } },

    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.luacheck,
    null_ls.builtins.diagnostics.vint,
    null_ls.builtins.diagnostics.markdownlint.with {
      extra_args = { "--config", path.join(path.config_dir, "markdownlint.json") },
      filetypes = { "markdown" },
    },

    null_ls.builtins.code_actions.shellcheck,
    null_ls.builtins.code_actions.gitsigns,
  }

  local default_opts = require("plugins.lsp").get_common_opts()
  null_ls.setup(vim.tbl_deep_extend("force", default_opts, M.config.setup))
end

return M
