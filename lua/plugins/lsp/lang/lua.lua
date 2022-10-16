local M = {}

M.lsp_setup = function()
  local status_ok, lua_dev = pcall(require, "neodev")
  if not status_ok then
    vim.cmd([[ packadd neodev.nvim ]])
    lua_dev = require("neodev")
  end

  lua_dev.setup({
    library = {
      enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
      -- these settings will be used for your Neovim config directory
      runtime = true, -- runtime path
      types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      plugins = true, -- installed opt or start plugins in packpath
      -- you can also specify the list of plugins to make available as a workspace library
      -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
    },
    setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
    -- for your Neovim config directory, the config.library settings will be used as is
    -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
    -- for any other directory, config.library.enabled will be set to false
    -- override = function(root_dir, options) end,
  })
  local lspconfig = {
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
  }

  local common_config = {
    on_attach = require("plugins.lsp").common_on_attach,
    capabilities = require("plugins.lsp").common_capabilities(),
  }
  lspconfig = vim.tbl_deep_extend("force", common_config, lspconfig)
  require("lspconfig")["sumneko_lua"].setup(lspconfig)
end

return M
