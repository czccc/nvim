local M = {}

M.packer = {
  "rcarriga/vim-ultest",
  requires = {
    {
      "vim-test/vim-test",
      event = "BufRead",
    },
  },
  run = ":UpdateRemotePlugins",
  setup = function()
    require("plugins.test").setup_ultest()
  end,
  event = "BufRead",
  opt = true,
}

vim.g["test#strategy"] = "asyncrun"
vim.g.ultest_use_pty = 1
vim.g.ultest_output_on_line = 0
vim.g.ultest_summary_width = 30

M.setup_ultest = function()
  utils.Key("n", "]t", "<Plug>(ultest-next-fail)", "Next Failed Test")
  utils.Key("n", "[t", "<Plug>(ultest-prev-fail)", "Previous Failed Test")
  utils.load_wk({
    u = { "<cmd>UltestSummary<cr>", "Ultest Summary" },
    l = { "<cmd>UltestLast<cr>", "Ultest Last" },
    n = { "<cmd>UltestNearest<cr>", "Ultest Nearest" },
    s = { "<cmd>UltestStop<cr>", "Ultest Stop" },
  }, { prefix = "<Leader>t", mode = "n" })
  utils.Group("UltestNoWrap"):cmd("FileType"):pattern("UltestSummary"):command("setlocal nowrap"):set()
end

return M
