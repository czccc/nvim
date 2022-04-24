local M = {}
-- local Log = require("core.log")
local AuCmd = require("utils").AuCmd
local Group = require("utils").Group

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
  }),
  Group("UserFileTypeSetting"):extend({
    AuCmd("FileType", { "markdown", "gitcommit" }, "setlocal spell wrap"),
    AuCmd(
      "FileType",
      { "go" },
      "setlocal noexpandtab copyindent preserveindent shiftwidth=2 tabstop=2 softtabstop=0 wrap"
    ),
    AuCmd("FileType", { "go" }, [[setlocal listchars=tab:\ \ ,nbsp:+,trail:·,extends:→,precedes:←]]),
  }),
  Group("UserBufferQuit"):extend({
    AuCmd("FileType", { "alpha", "floaterm" }, "nnoremap <silent> <buffer> q :q<CR>"),
    AuCmd(
      "FileType",
      { "qf", "help", "man", "lspinfo", "lsp-installer", "null-ls-info" },
      "nnoremap <silent> <buffer> q :close<CR>"
    ),
  }),
  Group("UserBufferSetting"):extend({
    AuCmd("TermOpen", "*", "setlocal nonumber norelativenumber"),
    AuCmd("FileType", "qf", "setlocal nobuflisted"),
    AuCmd("FileType", "Outline", "setlocal signcolumn=no nowrap"),
    AuCmd("user", "TelescopePreviewerLoaded", "setlocal number relativenumber wrap list"),
    AuCmd("BufWinEnter", "dashboard", "setlocal cursorline signcolumn=yes cursorcolumn number"),
  }),
  Group("UserFormatOnSave"):extend({
    AuCmd("BufWritePre", "*", wrap(vim.lsp.buf.formatting_sync, {}, 1000)),
  }),
  Group("UserAddHighlight"):extend({
    AuCmd("ColorScheme", "*", wrap(require("core.colors").setup_highlights)),
  }),
}

M.setup = function()
  for _, group in ipairs(M.autocommands) do
    group:set()
  end
end

return M
