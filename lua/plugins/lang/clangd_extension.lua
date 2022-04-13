local M = {}

M.setup = function()
  local status_ok, clangd_extensions = pcall(require, "clangd_extensions")
  if not status_ok then
    return
  end

  local clangd_flags = {
    "--background-index",
    "-j=12",
    "--all-scopes-completion",
    "--pch-storage=disk",
    "--clang-tidy",
    "--log=error",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--header-insertion-decorators",
    "--enable-config",
    "--offset-encoding=utf-16",
    "--ranking-model=heuristics",
    "--folding-ranges",
  }
  clangd_extensions.setup {
    server = {
      -- options to pass to nvim-lspconfig
      -- i.e. the arguments to require("lspconfig").clangd.setup({})
      cmd = { "clangd", unpack(clangd_flags) },
      on_attach = function(client, bufnr)
        require("plugins.lsp").common_on_attach(client, bufnr)
        require("plugins.which_key").register({
          ["m"] = {
            s = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch Source Header" },
            i = { "<cmd>ClangdSymbolInfo<cr>", "Symbol Info" },
            t = { "<cmd>ClangdTypeHierarchy<cr>", "Type Hierarchy" },
            T = { "<cmd>ClangdToggleInlayHints<cr>", "Toggle Inlay Hints" },
            m = { "<cmd>ClangdMemoryUsage<cr>", "Memory Usage" },
            a = { "<cmd>ClangdAST<cr>", "AST" },
          },
        }, { mode = "n", buffer = bufnr, prefix = "<Leader>" })
      end,
      on_init = require("plugins.lsp").common_on_init,
      capabilities = require("plugins.lsp").common_capabilities(),
    },
    extensions = {
      -- defaults:
      -- Automatically set inlay hints (type hints)
      autoSetHints = true,
      -- Whether to show hover actions inside the hover window
      -- This overrides the default hover handler
      hover_with_actions = true,
      -- These apply to the default ClangdSetInlayHints command
      inlay_hints = {
        -- Only show inlay hints for the current line
        only_current_line = false,
        -- Event which triggers a refersh of the inlay hints.
        -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
        -- not that this may cause  higher CPU usage.
        -- This option is only respected when only_current_line and
        -- autoSetHints both are true.
        only_current_line_autocmd = "CursorHold",
        -- wheter to show parameter hints with the inlay hints or not
        show_parameter_hints = true,
        -- whether to show variable name before type hints with the inlay hints or not
        show_variable_name = false,
        -- prefix for parameter hints
        parameter_hints_prefix = "<- ",
        -- prefix for all the other hints (type, chaining)
        other_hints_prefix = "=> ",
        -- whether to align to the length of the longest line in the file
        max_len_align = false,
        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,
        -- whether to align to the extreme right or not
        right_align = false,
        -- padding from the right if right_align is true
        right_align_padding = 7,
        -- The color of the hints
        highlight = "Comment",
      },
    },
  }
end

return M