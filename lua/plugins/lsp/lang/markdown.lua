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
  utils.Group("UserMarkdownPreview")
    :cmd("FileType")
    :pattern("markdown")
    :callback(function()
      utils.Key("n", "<Leader>mp", "<cmd>MarkdownPreview<cr>", "Preview"):buffer():set()
    end)
    :set()
end

M.setup_vim_markdown = function()
  vim.g.vim_markdown_folding_disabled = 1
  vim.g.vim_markdown_no_default_key_mappings = 1
  vim.g.vim_markdown_toc_autofit = 1
  vim.g.vim_markdown_frontmatter = 1

  utils.Group("UserVimMarkdown")
    :cmd("FileType")
    :pattern("markdown")
    :callback(function()
      utils.Key("n", "<Leader>mh", "<cmd>HeaderDecrease<cr>", "Header Decrease"):buffer():set()
      utils.Key("n", "<Leader>ml", "<cmd>HeaderIncrease<cr>", "Header Increase"):buffer():set()
      utils.Key("n", "<Leader>mf", "<cmd>TableFormat<cr>", "Table Format"):buffer():set()
      utils.Key("n", "<Leader>mt", "<cmd>Toc<cr>", "Toc"):buffer():set()
    end)
    :set()
end

M.setup_vim_markdown_toc = function()
  -- vim.g.vmt_auto_update_on_save = 0
  -- vim.g.vmt_dont_insert_fence = 1
  -- vim.g.vmt_cycle_list_item_markers = 1
  vim.g.vmt_include_headings_before = 1

  utils.Group("UserVimMarkdown")
    :cmd("FileType")
    :pattern("markdown")
    :callback(function()
      utils.Key("n", "<Leader>mg", "<cmd>GenTocGFM<cr>", "Gen Toc GFM"):buffer():set()
      utils.Key("n", "<Leader>mu", "<cmd>UpdateToc<cr>", "Update Toc"):buffer():set()
    end)
    :set()
end

return M
