local M = {}
local AuCmd = utils.AuCmd
local Group = utils.Group

M.autocommands = {
  Group("UserGeneralSetting"):extend({
    AuCmd("VimResized", "*", "tabdo wincmd ="),
    AuCmd("WinEnter", "*", "checktime"),
    AuCmd("TextYankPost", "*", wrap(require("vim.highlight").on_yank, { higroup = "Search", timeout = 200 })),
    AuCmd(
      { "BufWinEnter", "BufRead", "BufNewFile" },
      "*",
      "setlocal formatoptions-=c formatoptions-=r formatoptions-=o"
    ),
    AuCmd("BufReadPost", "*", function()
      local last_pos = vim.fn.line("'\"")
      if not vim.fn.expand("%:p"):match(".git") and last_pos > 1 and last_pos <= vim.fn.line("$") then
        vim.cmd("normal! g'\"")
        -- vim.cmd("normal zz")
      end
    end),
  }),
  Group("UserFileTypeSetting"):extend({
    AuCmd("FileType", { "markdown", "gitcommit" }, "setlocal spell wrap"),
    AuCmd("FileType", "python", "setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4"),
    AuCmd("FileType", "go", "setlocal noexpandtab shiftwidth=2 tabstop=2 softtabstop=0"),
    AuCmd("FileType", "go", [[setlocal listchars=tab:\ \ ,nbsp:+,trail:·,extends:→,precedes:←]]),
  }),
  Group("UserBufferQuit"):extend({
    AuCmd(
      "FileType",
      { "qf", "help", "man", "lspinfo", "lsp-installer", "null-ls-info" },
      "nnoremap <silent> <buffer> q :close<CR>"
    ),
  }),
  Group("UserBufferSetting"):extend({
    AuCmd("TermOpen", "*", "setlocal nonumber norelativenumber"),
    AuCmd("TermOpen", "term://*", "nnoremap <silent> <buffer> q :q<CR>"),
    AuCmd("FileType", "qf", "setlocal nobuflisted"),
    AuCmd("FileType", "Outline", "setlocal signcolumn=no nowrap"),
    AuCmd("BufWinEnter", "dashboard", "setlocal cursorline signcolumn=yes cursorcolumn number"),
  }),
}

M.setup = function()
  for _, group in ipairs(M.autocommands) do
    group:set()
  end
end

return M
