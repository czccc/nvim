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
    "ray-x/go.nvim",
    requires = {
      "ray-x/guihua.lua",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require("plugins.lang.go").setup()
    end,
    ft = { "go" },
  },
  {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    ft = "markdown",
    config = function()
      require("plugins.lang").setup_markdown_preview()
    end,
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
M.setup_markdown_preview = function()
  local utils = require("utils")
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
  local utils = require("utils")
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
  local utils = require("utils")
  utils.Group("UserVimMarkdown")
    :cmd("FileType")
    :pattern("markdown")
    :callback(function()
      utils.Key("n", "<Leader>mg", "<cmd>GenTocGFM<cr>", "Gen Toc GFM"):buffer():set()
      utils.Key("n", "<Leader>mu", "<cmd>UpdateToc<cr>", "Update Toc"):buffer():set()
    end)
    :set()
end

M.add_md_toc_mapping = function()
  -- require("plugins.which_key").register()
end

return M
