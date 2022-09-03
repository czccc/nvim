local M = {}

M.setup = function()
  utils.Group(
    "UserGeneralSetting",
    { "VimResized", "*", "tabdo wincmd =" },
    { "WinEnter", "*", "checktime" },
    { "TextYankPost", "*", wrap(require("vim.highlight").on_yank, { higroup = "Search", timeout = 200 }) },
    {
      { "BufWinEnter", "BufRead", "BufNewFile" },
      "*",
      "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
    },
    {
      "BufReadPost",
      "*",
      function()
        local last_pos = vim.fn.line("'\"")
        if not vim.fn.expand("%:p"):match(".git") and last_pos > 1 and last_pos <= vim.fn.line("$") then
          vim.cmd("normal! g'\"")
          -- vim.cmd("normal zz")
        end
      end,
    }
  )

  utils.Group(
    "UserFileTypeSetting",
    { "FileType", { "markdown", "gitcommit" }, "setlocal wrap" },
    { "FileType", "python", "setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4" },
    { "FileType", "go", "setlocal noexpandtab shiftwidth=2 tabstop=2 softtabstop=0" },
    { "FileType", "go", [[setlocal listchars=tab:\ \ ,nbsp:+,trail:·,extends:→,precedes:←]] }
  )

  utils.Group("UserBufferQuit", {
    "FileType",
    { "qf", "help", "man", "lspinfo", "lsp-installer", "null-ls-info" },
    "nnoremap <silent> <buffer> q :close<CR>",
  })

  utils.Group(
    "UserBufferSetting",
    { "TermOpen", "*", "setlocal nonumber norelativenumber" },
    { "TermOpen", "term://*", "nnoremap <silent> <buffer> q :q<CR>" },
    { "FileType", "qf", "setlocal nobuflisted" },
    { "FileType", "Outline", "setlocal signcolumn=no nowrap" },
    { "BufWinEnter", "dashboard", "setlocal cursorline signcolumn=yes cursorcolumn number" }
  )

  -- utils.Group("UserFoldViewSave", { "BufWinLeave", "*.*", "mkview" }, { "BufWinEnter", "*.*", "silent loadview" })
end

return M
