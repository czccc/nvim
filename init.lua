-- require("core").config()
-- require("core").setup()

if not vim.g.vscode then
  require("core").load_core()
  require("core").load_plugins()
end
