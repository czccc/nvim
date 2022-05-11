local M = {}

M.lsp_setup = function()
  local status_ok, lua_dev = pcall(require, "lua-dev")
  if not status_ok then
    vim.cmd([[ packadd lua-dev.nvim ]])
    lua_dev = require("lua-dev")
  end

  local config = lua_dev.setup({
    library = {
      vimruntime = true, -- runtime path
      types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      -- plugins = true, -- installed opt or start plugins in packpath
      -- you can also specify the list of plugins to make available as a workspace library
      -- plugins = { "plenary.nvim" },
    },
    lspconfig = {
      settings = {
        Lua = {
          format = {
            enable = false,
            -- Put format options here
            -- NOTE: the value should be STRING!!
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
            },
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
              [join_paths(utils.Path.config_dir, "lua")] = true,
            },
            maxPreload = 100000,
            preloadFileSize = 10000,
          },
        },
      },
    },
  })

  local common_config = {
    on_attach = require("plugins.lsp").common_on_attach,
    capabilities = require("plugins.lsp").common_capabilities(),
  }
  config = vim.tbl_deep_extend("force", common_config, config)
  require("lspconfig")["sumneko_lua"].setup(config)
end

return M
