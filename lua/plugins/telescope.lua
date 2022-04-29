local M = {}

M.packers = {
  {
    "nvim-telescope/telescope.nvim",
    disable = false,
    config = function()
      require("plugins.telescope").setup()
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    disable = false,
    run = "make",
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    requires = { "tami5/sqlite.lua" },
  },
  -- {
  --   "nvim-telescope/telescope-file-browser.nvim",
  -- },
  -- {
  --   "nvim-telescope/telescope-ui-select.nvim",
  -- },
  {
    "stevearc/dressing.nvim",
    config = function()
      require("plugins.telescope").setup_dressing()
    end,
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
    -- mappings = {
    --   i = {
    --     ["<C-c>"] = actions.close,
    --     ["<C-y>"] = actions.which_key,
    --     ["<C-j>"] = actions.cycle_history_next,
    --     ["<C-k>"] = actions.cycle_history_prev,
    --     ["<C-n>"] = actions.move_selection_next,
    --     ["<C-p>"] = actions.move_selection_previous,
    --     ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
    --     ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
    --     ["<CR>"] = actions.select_default + actions.center,
    --     ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
    --   },
    --   n = {
    --     ["<Esc>"] = actions.close,
    --     ["<c-j>"] = actions.cycle_history_next,
    --     ["<c-k>"] = actions.cycle_history_prev,
    --     ["<C-n>"] = actions.move_selection_next,
    --     ["<C-p>"] = actions.move_selection_previous,
    --     ["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
    --     ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_previous,
    --     ["<CR>"] = actions.select_default + actions.center,
    --     ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
    --   },
    -- },
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
        find_command = { "fd", "--type=file", "--hidden", "--smart-case" },
      },
      live_grep = {
        --@usage don't include the filename in the search results
        only_sort_text = true,
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
    ["ui-select"] = {
      require("telescope.themes").get_dropdown({
        -- even more opts
      }),
    },
  },
}
function M.set_keys()
  local LeaderfKey = require("utils.key").PrefixModeKey("<Leader>f", "n")
  local LeadersKey = require("utils.key").PrefixModeKey("<Leader>s", "n")
  local builtin = require("telescope.builtin")
  require("utils.key").load({
    LeaderfKey(""):group("Find Files"),
    LeaderfKey("b", M.curbuf, "Current Buffer"),
    LeaderfKey("B", M.curbuf_grep_cursor_string, "Buffer CurWord"),
    LeaderfKey("e", builtin.oldfiles, "History"),
    LeaderfKey("f", builtin.find_files, "History"),
    LeaderfKey("g", M.git_files, "Git Files"),
    LeaderfKey("j", builtin.jumplist, "Jump List"),
    LeaderfKey("l", builtin.resume, "Resume"),
    LeaderfKey("m", builtin.marks, "Marks"),
    LeaderfKey("P", M.project_search, "Project Files"),
    LeaderfKey("r", M.workspace_frequency, "Frequency"),
    LeaderfKey("s", M.git_status, "Git Status"),
    LeaderfKey("t", "<cmd>TodoTelescope<cr>", "Todo"),
    LeaderfKey("w", M.live_grep, "Live Grep"),
    LeaderfKey("W", M.grep_cursor_string, "Live Grep CurWord"),
    LeaderfKey("z", M.search_only_certain_files, "Certain Filetype"),

    LeadersKey(""):group("Search"),
    LeadersKey("b", builtin.git_branches, "Checkout Branch"),
    LeadersKey("c", builtin.colorscheme, "Colorschemes"),
    LeadersKey("C", function()
      require("telescope.builtin.internal").colorscheme({ enable_preview = true })
    end, "Colorschemes with Preview"),
    LeadersKey("h", builtin.help_tags, "Find Help"),
    LeadersKey("H", builtin.highlights, "Highlights"),
    LeadersKey("k", builtin.keymaps, "Keymaps"),
    LeadersKey("l", builtin.resume, "Resume"),
    LeadersKey("m", builtin.commands, "Commands"),
    LeadersKey("M", builtin.man_pages, "Man Pages"),
    LeadersKey("s", builtin.builtin, "Telescope"),
  })
end

function M.setup()
  local previewers = require("telescope.previewers")
  local sorters = require("telescope.sorters")
  local actions = require("telescope.actions")

  M.config = vim.tbl_extend("keep", {
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    file_sorter = sorters.get_fuzzy_file,
    generic_sorter = sorters.get_generic_fuzzy_sorter,
    ---@usage Mappings are fully customizable. Many familiar mapping patterns are setup as defaults.
    mappings = {
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
      },
      n = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
      },
    },
  }, M.config)

  local telescope = require("telescope")
  telescope.setup(M.config)
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("frecency")
  -- require("telescope").load_extension "file_browser"
  -- require("telescope").load_extension "ui-select"

  utils.Group("UserTelescopeFoldFix")
    :cmd("BufRead", "*", function()
      utils.AuCmd("BufWinEnter", "*", "normal! zx"):once():set()
    end)
    :set()
  M.set_keys()
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
      vim.fn.input("Type: "),
    },
  })
end

function M.git_files()
  local path = vim.fn.expand("%:h")
  if path == "" then
    path = nil
  end

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

local visual_selection = function()
  local save_previous = vim.fn.getreg("a")
  vim.api.nvim_command('silent! normal! "ayiw')
  local selection = vim.fn.trim(vim.fn.getreg("a"))
  vim.fn.setreg("a", save_previous)
  return vim.fn.substitute(selection, [[\n]], [[\\n]], "g")
end

function M.grep_cursor_string()
  local opts = ivy_opts()
  opts.default_text = visual_selection()
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

function M.curbuf_grep_cursor_string()
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

function M.file_browser()
  local opts = dropdown_opts()
  require("telescope").extensions.file_browser.file_browser(opts)
end

function M.projects()
  local opts = dropdown_opts()
  opts.initial_mode = "normal"
  require("telescope").extensions.projects.projects(opts)
end

return M
