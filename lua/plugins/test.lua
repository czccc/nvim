local M = {}

M.packers = {
  {
    "nvim-neotest/neotest",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
      "vim-test/vim-test",
    },
    setup = function()
      require("plugins.test").setup_neotest()
    end,
    event = "BufRead",
    opt = true,
  },
  -- {
  --   "rcarriga/vim-ultest",
  --   requires = {
  --     {
  --       "vim-test/vim-test",
  --       event = "BufRead",
  --     },
  --   },
  --   run = ":UpdateRemotePlugins",
  --   setup = function()
  --     require("plugins.test").setup_ultest()
  --   end,
  --   event = "BufRead",
  --   opt = true,
  -- },
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
  utils.Group("UltestNoWrap", { "FileType", "UltestSummary", "setlocal nowrap" })
end

M.setup_neotest = function()
  local status_ok, neotest = pcall(require, "neotest")
  if not status_ok then
    vim.notify("neotest not found")
    return
  end
  neotest.setup({
    adapters = {
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        dap = { justMyCode = false },
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        args = { "--log-level", "DEBUG" },
        -- Runner to use. Will use pytest if available by default.
        -- Can be a function to return dynamic value.
        runner = "pytest",

        -- Returns if a given file path is a test file.
        -- NB: This function is called a lot so don't perform any heavy tasks within it.
        -- is_test_file = function(file_path)
        --   ...
        -- end,
      }),
      require("neotest-go"),
      require("neotest-plenary"),
      require("neotest-vim-test")({
        ignore_file_types = { "python", "vim", "lua" },
        allow_file_types = { "haskell", "elixir" },
      }),
    },
  })
  utils.Key("n", "[t", wrap(neotest.jump.prev), "Previous Test")
  utils.Key("n", "]t", wrap(neotest.jump.next), "Next Test")
  utils.Key("n", "[T", wrap(neotest.jump.prev, { status = "failed" }), "Previous Failed Test")
  utils.Key("n", "]T", wrap(neotest.jump.next, { status = "failed" }), "Next Failed Test")
  utils.load_wk({
    u = { wrap(neotest.summary.toggle), "Test Summary" },
    o = { wrap(neotest.output.open, { enter = true }), "Test Output" },
    l = { wrap(neotest.run.run_last), "Test Last" },
    n = { wrap(neotest.run.run), "Test Nearest" },
    f = { wrap(neotest.run.run, vim.fn.expand("%")), "Test File" },
    s = { wrap(neotest.run.stop), "Test Stop" },
  }, { prefix = "<Leader>t", mode = "n" })
end

return M
