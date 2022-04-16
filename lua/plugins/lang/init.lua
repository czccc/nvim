local M = {}

M.packers = {
  {
    "simrat39/rust-tools.nvim",
    -- "fabiocaruso/rust-tools.nvim",
    config = function()
      require("plugins.lang.rust_tools").setup()
    end,
    ft = { "rust", "rs" },
  },
  {
    "p00f/clangd_extensions.nvim",
    config = function()
      require("plugins.lang.clangd_extension").setup()
    end,
    ft = { "c", "cpp", "objc", "objcpp" },
  },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
  },
  -- {
  --   "preservim/vim-markdown",
  --   ft = "markdown",
  --   config = function()
  --     require("plugins.lang").setup_vim_markdown()
  --   end,
  -- },
  {
    "mzlogin/vim-markdown-toc",
    ft = "markdown",
    config = function()
      require("plugins.lang").setup_vim_markdown_toc()
    end,
  },
}

M.setup_vim_markdown = function()
  vim.g.vim_markdown_folding_disabled = 1
  vim.g.vim_markdown_no_default_key_mappings = 1
  vim.g.vim_markdown_toc_autofit = 1
  vim.g.vim_markdown_frontmatter = 1
  require("core.autocmds").define_augroups({
    add_vim_markdown_mapping = {
      { "FileType", "markdown", "nnoremap <silent> <buffer> <Leader>mh :HeaderDecrease<CR>" },
      { "FileType", "markdown", "nnoremap <silent> <buffer> <Leader>ml :HeaderIncrease<CR>" },
      { "FileType", "markdown", "nnoremap <silent> <buffer> <Leader>mf :TableFormat<CR>" },
      { "FileType", "markdown", "nnoremap <silent> <buffer> <Leader>mt :Toc<CR>" },
    },
  })
end

M.setup_vim_markdown_toc = function()
  -- vim.g.vmt_auto_update_on_save = 0
  -- vim.g.vmt_dont_insert_fence = 1
  -- vim.g.vmt_cycle_list_item_markers = 1
  vim.g.vmt_include_headings_before = 1
  require("core.autocmds").define_augroups({
    add_update_toc_mapping = {
      { "FileType", "markdown", "nnoremap <silent> <buffer> <Leader>mg :GenTocGFM<CR>" },
      { "FileType", "markdown", "nnoremap <silent> <buffer> <Leader>mu :UpdateToc<CR>" },
    },
  })
end

M.add_md_toc_mapping = function()
  -- require("plugins.which_key").register()
end

return M
