local M = {}

M.packer = {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v2.x",
  event = "BufRead",
  cmd = "Neotree",
  opt = true,
  wants = {
    "plenary.nvim",
    "nvim-web-devicons",
    "nui.nvim",
    -- "s1n7ax/nvim-window-picker",
  },
  requires = {
    "nvim-lua/plenary.nvim",
    "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    {
      -- only needed if you want to use the commands with "_with_window_picker" suffix
      "s1n7ax/nvim-window-picker",
      tag = "v1.*",
      config = function()
        require("window-picker").setup({
          autoselect_one = true,
          include_current = false,
          filter_rules = {
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { "neo-tree", "neo-tree-popup", "notify" },

              -- if the buffer type is one of following, the window will be ignored
              buftype = { "terminal", "quickfix" },
            },
          },
          fg_color = "#151820",
          other_win_hl_color = "#97ca72",
        })
      end,
    },
  },
  config = function()
    require("plugins.neotree").setup()
  end,
}

M.config = {
  close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      -- indent guides
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      -- expander config, needed for nesting files
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
      default = "",
      highlight = "NeoTreeFileIcon",
    },
    modified = {
      symbol = "",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },
    git_status = {
      symbols = {
        -- Change type
        added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted = "✖", -- this can only be used in the git_status source
        renamed = "", -- this can only be used in the git_status source
        -- Status type
        -- untracked = "",
        untracked = "✚",
        ignored = "",
        unstaged = "",
        -- unstaged = "",
        staged = "",
        conflict = "",
      },
    },
  },
  window = {
    position = "left",
    width = 30,
    mappings = {
      ["<space>"] = "none",
      -- ["<Tab>"] = "none",
      ["<Tab>"] = wrap(vim.cmd, "wincmd l"),
      ["<2-LeftMouse>"] = "open_with_window_picker",
      ["<cr>"] = "open_with_window_picker",
      ["o"] = "open",
      -- ["S"] = "open_split",
      -- ["s"] = "open_vsplit",
      ["S"] = "split_with_window_picker",
      ["s"] = "vsplit_with_window_picker",
      ["w"] = "open_with_window_picker",
      ["t"] = "open_tabnew",
      ["C"] = "close_node",
      ["a"] = {
        "add",
        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
        config = {
          show_path = "none", -- "none", "relative", "absolute"
        },
      },
      ["A"] = "add_directory",
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy", -- takes text input for destination
      ["m"] = "move", -- takes text input for destination
      ["q"] = "close_window",
      ["R"] = "refresh",
      ["?"] = "show_help",
      ["J"] = function(state)
        local tree = state.tree
        local node = tree:get_node()
        local siblings = tree:get_nodes(node:get_parent_id())
        local renderer = require("neo-tree.ui.renderer")
        renderer.focus_node(state, siblings[#siblings]:get_id())
      end,
      ["K"] = function(state)
        local tree = state.tree
        local node = tree:get_node()
        local siblings = tree:get_nodes(node:get_parent_id())
        local renderer = require("neo-tree.ui.renderer")
        renderer.focus_node(state, siblings[1]:get_id())
      end,
    },
  },
  nesting_rules = {},
  filesystem = {
    filtered_items = {
      visible = true, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_hidden = true, -- only works on Windows for hidden files/directories
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        ".git",
        --"node_modules"
      },
      hide_by_pattern = { -- uses glob style patterns
        --"*.meta"
      },
      never_show = { -- remains hidden even if visible is toggled to true
        --".DS_Store",
        --"thumbs.db"
      },
    },
    follow_current_file = true, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    group_empty_dirs = true, -- when true, empty folders will be grouped together
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_current",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
    -- instead of relying on nvim autocmd events.
    window = {
      mappings = {
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["[g"] = "prev_git_modified",
        ["]g"] = "next_git_modified",
      },
    },
  },
  buffers = {
    follow_current_file = true, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    group_empty_dirs = true, -- when true, empty folders will be grouped together
    show_unloaded = true,
    window = {
      mappings = {
        ["bd"] = "buffer_delete",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
      },
    },
  },
  git_status = {
    window = {
      position = "float",
      mappings = {
        ["A"] = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      },
    },
  },
}

M.init = function()
  vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
  utils.Key("n", "<Leader>e", "<cmd>Neotree filesystem<cr>", "Explorer")
  utils.Key("n", "<Leader>E", "<cmd>Neotree toggle<cr>", "Explorer")
  utils.Key("n", "<Leader>ug", "<cmd>Neotree git_status left<cr>", "Git Status")
  utils.Key("n", "<Leader>uG", "<cmd>Neotree git_status float<cr>", "Git Status")
  utils.Key("n", "<Leader>ub", "<cmd>Neotree buffers left<cr>", "Opened Files")
  utils.Key("n", "<Leader>uB", "<cmd>Neotree buffers float<cr>", "Opened Files")
  utils.Group("UserNeoTreeNoNumber", { "FileType", "neo-tree", "setlocal nonumber norelativenumber" })
end

M.setup = function()
  require("neo-tree").setup(M.config)
end

return M
