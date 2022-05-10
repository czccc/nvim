-- require("core").config()
-- require("core").setup()

if not vim.fn.exists("g:vscode") then
  require("core").load_core()
  require("core").load_plugins()
else
  require("core.vscode")
end
