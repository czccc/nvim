local M = {}

M.packers = {
  { "nvim-lua/popup.nvim" },
  { "nvim-lua/plenary.nvim" },
  { "lewis6991/impatient.nvim" },
  { "kyazdani42/nvim-web-devicons" },
  {
    "antoinemadec/FixCursorHold.nvim",
    event = "BufRead",
  },
  { "mtdl9/vim-log-highlighting", ft = { "text", "log" } },
  { "b0o/schemastore.nvim" },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup({ easing_function = "quadratic" })
    end,
    event = "BufRead",
    disable = false,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ "*" }, { css = true })
    end,
    event = { "BufRead" },
  },
  {
    "ethanholz/nvim-lastplace",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit",
          "gitrebase",
          "svn",
          "hgcommit",
        },
        lastplace_open_folds = true,
      })
    end,
    event = "BufWinEnter",
    disable = false,
  },
  -- {
  --   "tpope/vim-surround",
  -- },
  {
    "machakann/vim-sandwich",
    config = function()
      require("plugins.misc").setup_sandwich()
    end,
    event = "BufRead",
  },
}

M.setup_sandwich = function()
  vim.cmd([[
    let g:sandwich_no_default_key_mappings = 1
    silent! nmap <unique><silent> Sd <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)
    silent! nmap <unique><silent> Sr <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)
    silent! nmap <unique><silent> Sdb <Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)
    silent! nmap <unique><silent> Srb <Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)

    let g:operator_sandwich_no_default_key_mappings = 1
    let g:textobj_sandwich_no_default_key_mappings = 1
    " add
    silent! map <unique> Sa <Plug>(operator-sandwich-add)
    " delete
    silent! xmap <unique> Sd <Plug>(operator-sandwich-delete)
    " replace
    silent! xmap <uni]que> Sr <Plug>(operator-sandwich-replace)
  ]])
  utils.Key("n", "S"):group("Sandwich"):set()
end

return M
