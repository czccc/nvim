-- require("core").config()
-- require("core").setup()

if vim.fn.exists("g:vscode") == 0 then
  require("core").load_core()
  require("core").load_plugins()
else
  require("core.vscode")
end
