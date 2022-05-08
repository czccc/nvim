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
  utils.Key("n", "]t", "<Plug>(ultest-next-fail)", "Next Failed Test"):set()
  utils.Key("n", "[t", "<Plug>(ultest-prev-fail)", "Previous Failed Test"):set()
  utils.Key("n", "<leader>tu", "<cmd>UltestSummary<cr>", "Ultest Summary"):set()
  utils.Key("n", "<leader>tl", "<cmd>UltestLast<cr>", "Ultest Last"):set()
  utils.Key("n", "<leader>tn", "<cmd>UltestNearest<cr>", "Ultest Nearest"):set()
  utils.Key("n", "<leader>ts", "<cmd>UltestStop<cr>", "Ultest Stop"):set()
  utils.Group("UltestNoWrap"):cmd("FileType"):pattern("UltestSummary"):command("setlocal nowrap"):set()
end

return M
