local status_ok, lua_dev = pcall(require, "lua-dev")
if not status_ok then
  vim.cmd([[ packadd lua-dev.nvim ]])
  lua_dev = require("lua-dev")
end

local dev_opts = {
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
}

return lua_dev.setup(dev_opts)
