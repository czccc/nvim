local M = {}

M.packers = {
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    -- event = "BufRead",
    -- opt = true,
    config = function()
      require("plugins.treesitter").setup()
    end,
    requires = {
      { "nvim-treesitter/playground", opt = true, cmd = "TSHighlightCapturesUnderCursor" },
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-textobjects",
      -- "RRethy/nvim-treesitter-textsubjects",
      "p00f/nvim-ts-rainbow",
      "andymass/vim-matchup",
      {
        "nvim-treesitter/nvim-treesitter-context",
        config = function()
          require("plugins.treesitter").setup_context()
        end,
      },
    },
  },
}

M.opts = {
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "go",
    "javascript",
    "json",
    "lua",
    "python",
    "typescript",
    "css",
    "rust",
    "java",
    "yaml",
    "query",
    "markdown",
    "norg",
  }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ignore_install = {},
  matchup = {
    enable = true, -- mandatory, false will disable the whole extension
    -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
    matchparen_offscreen = { method = "popup" },
    -- vim.cmd([[ let g:matchup_matchparen_offscreen = {'method': 'popup'} ]]),
    vim.cmd([[ let g:matchup_matchparen_offscreen = {'method': 'status_manual'} ]]),
  },
  highlight = {
    enable = true, -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
    disable = { "latex" },
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-n>",
      node_incremental = "<C-n>",
      scope_incremental = "<C-m>",
      node_decremental = "<C-r>",
    },
  },
  context_commentstring = {
    enable = true,
    config = {
      -- Languages that have a single comment style
      lua = "-- %s",
      typescript = "// %s",
      css = "/* %s */",
      scss = "/* %s */",
      html = "<!-- %s -->",
      svelte = "<!-- %s -->",
      vue = "<!-- %s -->",
      json = "",
    },
  },
  -- indent = {enable = true, disable = {"python", "html", "javascript"}},
  -- TODO seems to be broken
  indent = {
    enable = true,
    disable = { "yaml" },
  },
  autotag = { enable = false },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    swap = {
      enable = false,
      swap_next = {
        ["<leader><M-a>"] = "@parameter.inner",
        ["<leader><M-f>"] = "@function.outer",
        ["<leader><M-e>"] = "@element",
      },
      swap_previous = {
        ["<leader><M-A>"] = "@parameter.inner",
        ["<leader><M-F>"] = "@function.outer",
        ["<leader><M-E>"] = "@element",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
        ["]c"] = "@class.outer",
      },
      goto_next_end = {
        ["]F"] = "@function.outer",
        ["]C"] = "@class.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
        ["[c"] = "@class.outer",
      },
      goto_previous_end = {
        ["[F"] = "@function.outer",
        ["[C"] = "@class.outer",
      },
    },
    lsp_interop = {
      enable = true,
      border = "none",
      peek_definition_code = {
        ["<leader>lf"] = "@function.outer",
        ["<leader>lc"] = "@class.outer",
      },
    },
  },
  textsubjects = {
    enable = false,
    prev_selection = ",",
    keymaps = {
      ["."] = "textsubjects-smart",
      -- [";"] = "textsubjects-big",
      [";"] = "textsubjects-container-outer",
      ["i;"] = "textsubjects-container-inner",
    },
  },
  playground = {
    enable = false,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
  rainbow = {
    enable = true,
    extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
    max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
    -- colors = {
    -- "#ca72e4",
    -- "#97ca72",
    -- "#ef5f6b",
    -- "#d99a5e",
    -- "#5ab0f6",
    -- "#ebc275",
    -- "#4dbdcb",
    -- }, -- table of hex strings
    -- termcolors = {} -- table of colour name strings
  },
}

function M.setup()
  -- avoid running in headless mode since it's harder to detect failures
  if #vim.api.nvim_list_uis() == 0 then
    vim.notify("headless mode detected, skipping running setup for treesitter", vim.log.levels.WARN)
    return
  end

  local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
  if not status_ok then
    vim.notify("Failed to load nvim-treesitter.configs", vim.log.levels.ERROR)
    return
  end

  treesitter_configs.setup(M.opts)
  require("nvim-treesitter.install").prefer_git = true

  utils.load({
    utils.IKey("o", "af"):desc("Function Outer"),
    utils.IKey("o", "if"):desc("Function Inner"),
    utils.IKey("o", "ac"):desc("Class Outer"),
    utils.IKey("o", "ic"):desc("Class Inner"),
    utils.IKey("o", "al"):desc("Loop Outer"),
    utils.IKey("o", "il"):desc("Loop Inner"),
    utils.IKey("o", "aa"):desc("Parameter Outer"),
    utils.IKey("o", "ia"):desc("Parameter Inner"),

    utils.IKey("n", "]f"):desc("Next Function Start"),
    utils.IKey("n", "]c"):desc("Next Class Start"),
    utils.IKey("n", "]F"):desc("Next Function End"),
    utils.IKey("n", "]C"):desc("Next Class End"),
    utils.IKey("n", "[f"):desc("Previous Function Start"),
    utils.IKey("n", "[c"):desc("Previous Class Start"),
    utils.IKey("n", "[F"):desc("Previous Function End"),
    utils.IKey("n", "[C"):desc("Previous Class End"),
    utils.IKey("n", "<Leader>lf"):desc("Peek Function"),
    utils.IKey("n", "<Leader>lc"):desc("Peek Class"),
    utils.IKey("n", "<Leader>ut", "<cmd>TSHighlightCapturesUnderCursor<cr>", "TSHighlightCapturesUnderCursor"),
  })
end

M.setup_context = function()
  require("treesitter-context").setup({
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    throttle = true, -- Throttles plugin updates (may improve performance)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
      -- For all filetypes
      -- Note that setting an entry here replaces all other patterns for this entry.
      -- By setting the 'default' entry below, you can control which nodes you want to
      -- appear in the context window.
      default = {
        "class",
        "function",
        "method",
        -- 'for', -- These won't appear in the context
        -- 'while',
        -- 'if',
        -- 'switch',
        -- 'case',
      },
      -- Example for a specific filetype.
      -- If a pattern is missing, *open a PR* so everyone can benefit.
      --   rust = {
      --       'impl_item',
      --   },
    },
    exact_patterns = {
      -- Example for a specific filetype with Lua patterns
      -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
      -- exactly match "impl_item" only)
      -- rust = true,
    },
  })
end

return M
