local M = {}
-- local Log = require("core.log")
local Cmd = require("utils.autocmd").Cmd
local Group = require("utils.autocmd").Group

M.autocommands = {
  Group("UserGeneralSetting"):extend({
    Cmd("VimResized"):pattern("*"):command("tabdo wincmd ="),
    Cmd("WinEnter"):pattern("*"):command("checktime"),
    Cmd("TextYankPost")
      :pattern("*")
      :callback(wrap(require("vim.highlight").on_yank, { higroup = "Search", timeout = 200 })),
    Cmd({ "BufWinEnter", "BufRead", "BufNewFile" })
      :pattern("*")
      :command("setlocal formatoptions-=c formatoptions-=r formatoptions-=o"),
  }),
  Group("UserFileTypeSetting"):extend({
    Cmd("FileType"):pattern({ "markdown", "gitcommit" }):command("setlocal spell wrap"),
    Cmd("FileType")
      :pattern({ "go" })
      :command("setlocal noexpandtab copyindent preserveindent shiftwidth=2 tabstop=2 softtabstop=0 wrap"),
  }),
  Group("UserBufferQuit"):extend({
    Cmd("FileType"):pattern({ "alpha", "floaterm" }):command("nnoremap <silent> <buffer> q :q<CR>"),
    Cmd("FileType")
      :pattern({ "qf", "help", "man", "lspinfo", "lsp-installer", "null-ls-info" })
      :command("nnoremap <silent> <buffer> q :close<CR>"),
  }),
  Group("UserBufferSetting"):extend({
    Cmd("TermOpen"):pattern("*"):command("setlocal nonumber norelativenumber"),
    Cmd("FileType"):pattern("qf"):command("setlocal nobuflisted"),
    Cmd("FileType"):pattern("Outline"):command("setlocal signcolumn=no nowrap"),
    Cmd("user"):pattern("TelescopePreviewerLoaded"):command("setlocal number relativenumber wrap list"),
    Cmd("BufWinEnter"):pattern("dashboard"):command("setlocal cursorline signcolumn=yes cursorcolumn number"),
  }),
  Group("UserFormatOnSave"):extend({
    Cmd("BufWritePre"):pattern("*"):callback(wrap(vim.lsp.buf.formatting_sync, {}, 1000)),
  }),
  Group("UserAddHighlight"):extend({
    Cmd("ColorScheme"):pattern("*"):callback(wrap(require("core.colors").setup_highlights)),
  }),
}

M.setup = function()
  for _, group in ipairs(M.autocommands) do
    group:set()
  end
end

return M
