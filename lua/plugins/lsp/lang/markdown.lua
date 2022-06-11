local M = {}

M.packers = {
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    opt = true,
    config = function()
      require("plugins.lsp.lang.markdown").setup_markdown_preview()
    end,
  },
  -- {
  --   "preservim/vim-markdown",
  --   ft = "markdown",
  --   config = function()
  --     require("plugins.lsp.lang.markdown").setup_vim_markdown()
  --   end,
  -- },
  {
    "mzlogin/vim-markdown-toc",
    ft = "markdown",
    config = function()
      require("plugins.lsp.lang.markdown").setup_vim_markdown_toc()
    end,
  },
}

M.setup_markdown_preview = function()
  utils.Group("UserMarkdownPreview", {
    "FileType",
    "markdown",
    function()
      utils.IKey("n", "<Leader>mp", "<cmd>MarkdownPreview<cr>", "Preview"):buffer():set()
    end,
  })
end

M.setup_vim_markdown = function()
  vim.g.vim_markdown_folding_disabled = 1
  vim.g.vim_markdown_no_default_key_mappings = 1
  vim.g.vim_markdown_toc_autofit = 1
  vim.g.vim_markdown_frontmatter = 1

  utils.IGroup("UserVimMarkdown", {
    "FileType",
    "markdown",
    function()
      utils.IKey("n", "<Leader>mh", "<cmd>HeaderDecrease<cr>", "Header Decrease"):buffer():set()
      utils.IKey("n", "<Leader>ml", "<cmd>HeaderIncrease<cr>", "Header Increase"):buffer():set()
      utils.IKey("n", "<Leader>mf", "<cmd>TableFormat<cr>", "Table Format"):buffer():set()
      utils.IKey("n", "<Leader>mt", "<cmd>Toc<cr>", "Toc"):buffer():set()
    end,
  })
end

M.setup_vim_markdown_toc = function()
  -- vim.g.vmt_auto_update_on_save = 0
  -- vim.g.vmt_dont_insert_fence = 1
  -- vim.g.vmt_cycle_list_item_markers = 1
  vim.g.vmt_include_headings_before = 1

  utils.IGroup("UserVimMarkdown", {
    "FileType",
    "markdown",
    function()
      utils.IKey("n", "<Leader>mg", "<cmd>GenTocGFM<cr>", "Gen Toc GFM"):buffer():set()
      utils.IKey("n", "<Leader>mu", "<cmd>UpdateToc<cr>", "Update Toc"):buffer():set()
    end,
  })
end

return M
