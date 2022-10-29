local M = {}

M.packers = {
  {
    "nvim-telescope/telescope.nvim",
    -- event = "VimEnter",
    -- cmd = { "Telescope" },
    -- module = "telescope",
    -- keys = { "<leader>s", "<leader>f" },
    -- opt = true,
    setup = function()
      require("plugins.telescope").set_keys()
    end,
    config = function()
      require("plugins.telescope").setup()
    end,
    wants = {
      "plenary.nvim",
      "popup.nvim",
      "telescope-frecency.nvim",
      "telescope-fzf-native.nvim",
      "dressing.nvim",
    },
    requires = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
      {
        "nvim-telescope/telescope-frecency.nvim",
        requires = { "tami5/sqlite.lua" },
      },
      {
        "stevearc/dressing.nvim",
        config = function()
          require("plugins.telescope").setup_dressing()
        end,
      },
      {
        "ThePrimeagen/harpoon",
        config = function()
          require("plugins.telescope").setup_harpoon()
        end,
      },
    },
  },
}

M.config = {
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "descending",
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.75,
      preview_cutoff = 120,
      horizontal = {
        mirror = false,
        preview_width = 0.6,
      },
      vertical = { mirror = false },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob=!.git/",
    },
    file_ignore_patterns = {
      "vendor/*",
      "%.lock",
      "__pycache__/*",
      "%.sqlite3",
      "%.ipynb",
      "node_modules/*",
      "%.jpg",
      "%.jpeg",
      "%.png",
      "%.svg",
      "%.otf",
      "%.ttf",
      ".git/",
      "%.webp",
      ".dart_tool/",
      ".github/",
      ".gradle/",
      ".idea/",
      ".settings/",
      ".vscode/",
      "__pycache__/",
      "build/",
      "env/",
      "gradle/",
      "node_modules/",
      "target/",
      "%.pdb",
      "%.dll",
      "%.class",
      "%.exe",
      "%.cache",
      "%.ico",
      "%.pdf",
      "%.dylib",
      "%.jar",
      "%.docx",
      "%.met",
      "smalljre_*/*",
      ".vale/",
    },
    path_display = { shorten = 10 },
    winblend = 6,
    border = {},
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    color_devicons = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    pickers = {
      find_files = {
        hidden = true,
      },
      live_grep = {
        --@usage don't include the filename in the search results
        -- only_sort_text = true,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    },
    frecency = {
      -- show_scores = true,
    },
  },
}

function M.set_keys()
  local builtin = require("telescope.builtin")
  utils.load_wk({
    name = "Find Files",
    b = { M.curbuf, "Current Buffer" },
    B = { M.curbuf_grep_cursor_string, "Buffer CurWord" },
    e = { builtin.oldfiles, "History" },
    f = { builtin.find_files, "History" },
    g = { M.git_files, "Git Files" },
    j = { builtin.jumplist, "Jump List" },
    l = { builtin.resume, "Resume" },
    m = { builtin.marks, "Marks" },
    P = { M.project_search, "Project Files" },
    r = { M.workspace_frequency, "Frequency" },
    s = { M.git_status, "Git Status" },
    t = { "<cmd>TodoTelescope<cr>", "Todo" },
    w = { M.live_grep, "Live Grep" },
    W = { M.grep_cursor_string, "Live Grep CurWord" },
    z = { M.search_only_certain_files, "Certain Filetype" },
  }, { prefix = "<Leader>f", mode = "n" })
  utils.load_wk({
    name = "Find Files",
    B = { M.curbuf_grep_visual_string, "Buffer CurWord" },
    W = { M.grep_visual_string, "Live Grep CurWord" },
  }, { prefix = "<Leader>f", mode = "v" })
  utils.load_wk({
    name = "Search",
    a = { builtin.autocommands, "Autocommands" },
    b = { builtin.git_branches, "Checkout Branch" },
    c = { builtin.colorscheme, "Colorschemes" },
    C = {
      function()
        builtin.colorscheme({ enable_preview = true })
      end,
      "Colorschemes with Preview",
    },
    h = { builtin.help_tags, "Find Help" },
    H = { builtin.highlights, "Highlights" },
    j = { builtin.command_history, "Command History" },
    J = { builtin.search_history, "Search History" },
    k = { builtin.keymaps, "Keymaps" },
    l = { builtin.resume, "Resume" },
    m = { builtin.commands, "Commands" },
    M = { wrap(builtin.man_pages, { sections = { "1", "3" } }), "Man Pages" },
    s = { builtin.builtin, "Telescope" },
  }, { prefix = "<Leader>s", mode = "n" })
end

function M.setup()
  local previewers = require("telescope.previewers")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")
  local action_layout = require("telescope.actions.layout")
  require("telescope").setup({
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    -- ignore files bigger than a threshold and don't preview binaries
    buffer_previewer_maker = function(filepath, bufnr, opts)
      opts = opts or {}
      filepath = vim.fn.expand(filepath)
      local Job = require("plenary.job")
      vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then
          return
        end
        if stat.size > 100000 then
          return
        else
          Job:new({
            command = "file",
            args = { "--mime-type", "-b", filepath },
            on_exit = function(j)
              local mime_type = vim.split(j:result()[1], "/", {})[1]
              if mime_type == "text" then
                previewers.buffer_previewer_maker(filepath, bufnr, opts)
              else
                -- maybe we want to write something to the buffer here
                vim.schedule(function()
                  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
                end)
              end
            end,
          }):sync()
        end
      end)
    end,
    file_sorter = sorters.get_fuzzy_file,
    generic_sorter = sorters.get_generic_fuzzy_sorter,

    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      layout_config = {
        width = 0.75,
        preview_cutoff = 120,
        horizontal = {
          mirror = false,
          preview_width = 0.6,
        },
        vertical = { mirror = false },
      },
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
        "--trim", -- add this value
        "--glob=!.git/",
      },
      mappings = {
        i = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-j>"] = actions.cycle_history_next,
          ["<C-k>"] = actions.cycle_history_prev,
          ["<M-p>"] = action_layout.toggle_preview,
        },
        n = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-j>"] = actions.cycle_history_next,
          ["<C-k>"] = actions.cycle_history_prev,
          ["<M-p>"] = action_layout.toggle_preview,
        },
      },
      file_ignore_patterns = {
        "vendor/*",
        "%.lock",
        "__pycache__/*",
        "%.sqlite3",
        "%.ipynb",
        "node_modules/*",
        "%.jpg",
        "%.jpeg",
        "%.png",
        "%.svg",
        "%.otf",
        "%.ttf",
        ".git/",
        "%.webp",
        ".dart_tool/",
        ".github/",
        ".gradle/",
        ".idea/",
        ".settings/",
        ".vscode/",
        "__pycache__/",
        "build/",
        "env/",
        "gradle/",
        "node_modules/",
        "target/",
        "%.pdb",
        "%.dll",
        "%.class",
        "%.exe",
        "%.cache",
        "%.ico",
        "%.pdf",
        "%.dylib",
        "%.jar",
        "%.docx",
        "%.met",
        "smalljre_*/*",
        ".vale/",
      },
      path_display = { shorten = 10 },
      winblend = 6,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      pickers = {
        find_files = {
          find_command = { "fd", "--type=file", "--hidden", "--smart-case", "--strip-cwd-prefix" },
        },
        live_grep = {
          --@usage don't include the filename in the search results
          -- only_sort_text = true,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      frecency = {
        -- show_scores = true,
      },
    },
  })

  require("telescope").load_extension("fzf")
  require("telescope").load_extension("frecency")

  utils.Group(
    "UserTelescopeFoldFix",
    {
      "BufRead",
      "*",
      function()
        utils.AuCmd("BufWinEnter", "*", "normal! zx"):once():set()
      end,
    }
    -- {
    --   "User",
    --   "TelescopePreviewerLoaded",
    --   "setlocal number relativenumber wrap list",
    -- },
  )
  -- utils.AuCmd("User", "TelescopePreviewerLoaded", "setlocal number relativenumber wrap list"),
end

M.setup_dressing = function()
  require("dressing").setup({
    input = {
      enabled = true,
      -- Default prompt string
      default_prompt = "Input:",
    },
    select = {
      -- Set to false to disable the vim.ui.select implementation
      enabled = true,

      -- Priority list of preferred vim.select implementations
      backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },

      -- Options for telescope selector
      -- These are passed into the telescope picker directly. Can be used like:
      -- telescope = require('telescope.themes').get_ivy({...})
      telescope = nil,

      -- Used to override format_item. See :help dressing-format
      format_item_override = {},

      -- see :help dressing_get_config
      get_config = nil,
    },
  })
end

M.setup_harpoon = function()
  require("harpoon").setup({
    global_settings = {
      -- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
      save_on_toggle = false,

      -- saves the harpoon file upon every change. disabling is unrecommended.
      save_on_change = true,

      -- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
      enter_on_sendcmd = false,

      -- closes any tmux windows harpoon that harpoon creates when you close Neovim.
      tmux_autoclose_windows = false,

      -- filetypes that you want to prevent from adding to the harpoon list menu.
      excluded_filetypes = { "harpoon" },

      -- set marks specific to each git branch inside git repository
      mark_branch = false,
    },
  })
  require("telescope").load_extension("harpoon")
  utils.load_wk({
    -- m = { require("harpoon.ui").toggle_quick_menu, "Harpoon" },
    h = { "<cmd>Telescope harpoon marks theme=dropdown<cr>", "Harpoon" },
    H = { require("harpoon.mark").add_file, "Harpoon Add" },
    n = { require("harpoon.ui").nav_next, "Harpoon Next" },
    p = { require("harpoon.ui").nav_prev, "Harpoon Previous" },
  }, { prefix = "<Leader>f", mode = "n" })
end

local function dropdown_opts()
  return require("telescope.themes").get_dropdown({
    winblend = 15,
    layout_config = {
      prompt_position = "top",
      width = 80,
      height = 20,
    },
    borderchars = {
      prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
    border = {},
    previewer = false,
    shorten_path = false,
  })
end

M.dropdown_opts = dropdown_opts

local function ivy_opts()
  return require("telescope.themes").get_ivy({
    layout_strategy = "bottom_pane",
    layout_config = {
      height = 25,
    },
    border = true,
    borderchars = {
      prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
    sorting_strategy = "ascending",
    ignore_filename = false,
  })
end

M.ivy_opts = ivy_opts

function M.lsp_definitions()
  local opts = ivy_opts()
  require("telescope.builtin").lsp_definitions(opts)
end

-- show refrences to this using language server
function M.lsp_references()
  local opts = ivy_opts()
  require("telescope.builtin").lsp_references(opts)
end

-- show implementations of the current thingy using language server
function M.lsp_implementations()
  local opts = ivy_opts()
  require("telescope.builtin").lsp_implementations(opts)
end

function M.find_buffers()
  local opts = dropdown_opts()
  require("telescope.builtin").buffers(opts)
end

function M.curbuf()
  local opts = dropdown_opts()
  require("telescope.builtin").current_buffer_fuzzy_find(opts)
end

function M.git_status()
  local opts = dropdown_opts()
  require("telescope.builtin").git_status(opts)
end

function M.search_only_certain_files()
  require("telescope.builtin").find_files({
    find_command = {
      "rg",
      "--files",
      "--type",
      vim.fn.input({ prompt = "Type: " }),
    },
  })
end

function M.git_files()
  local path = vim.fn.expand("%:h")

  local opts = dropdown_opts()
  opts.cwd = path
  opts.file_ignore_patterns = {
    "^[.]vale/",
  }
  require("telescope.builtin").git_files(opts)
end

function M.project_search()
  local ok = pcall(require("telescope.builtin").git_files)

  if not ok then
    require("telescope.builtin").find_files()
  end
end

function M.live_grep()
  local opts = ivy_opts()
  opts.file_ignore_patterns = {
    "vendor/*",
    "node_modules",
    "%.jpg",
    "%.jpeg",
    "%.png",
    "%.svg",
    "%.otf",
    "%.ttf",
  }
  require("telescope.builtin").live_grep(opts)
end

local cur_word = function()
  local save_previous = vim.fn.getreg("a")
  vim.api.nvim_command('silent! normal! "ayiw')
  local selection = vim.fn.trim(vim.fn.getreg("a"))
  vim.fn.setreg("a", save_previous)
  return vim.fn.substitute(selection, [[\n]], [[\\n]], "g")
end

function M.grep_cursor_string()
  local opts = ivy_opts()
  opts.default_text = cur_word()
  require("telescope.builtin").live_grep(opts)
end

function M.curbuf_grep_cursor_string()
  local opts = ivy_opts()
  opts.default_text = cur_word()
  require("telescope.builtin").current_buffer_fuzzy_find(opts)
end

local visual_selection = function()
  local save_previous = vim.fn.getreg("a")
  vim.api.nvim_command('silent! normal! "ay')
  local selection = vim.fn.trim(vim.fn.getreg("a"))
  vim.fn.setreg("a", save_previous)
  return vim.fn.substitute(selection, [[\n]], [[\\n]], "g")
end

function M.grep_visual_string()
  local opts = ivy_opts()
  opts.default_text = visual_selection()
  require("telescope.builtin").live_grep(opts)
end

function M.curbuf_grep_visual_string()
  local opts = ivy_opts()
  opts.default_text = visual_selection()
  require("telescope.builtin").current_buffer_fuzzy_find(opts)
end

function M.workspace_frequency()
  local opts = {
    default_text = ":CWD:",
  }
  require("telescope").extensions.frecency.frecency(opts)
end

return M
