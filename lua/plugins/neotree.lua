local M = {}

M.packer = {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v2.x",
  requires = {
    "nvim-lua/plenary.nvim",
    "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
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
      folder_empty = "ﰊ",
      default = "*",
    },
    modified = {
      symbol = "",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
    },
    git_status = {
      symbols = {
        -- Change type
        -- added = "✚",
        deleted = "✖",
        -- modified = "",
        modified = "",
        renamed = "",
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
      ["<Tab>"] = "none",
      ["<2-LeftMouse>"] = "open",
      ["<cr>"] = "open",
      ["o"] = "open",
      ["S"] = "open_split",
      ["s"] = "open_vsplit",
      ["C"] = "close_node",
      ["R"] = "refresh",
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
  renderers = {
    directory = {
      { "indent" },
      { "icon" },
      { "current_filter" },
      {
        "container",
        width = "100%",
        right_padding = 1,
        --max_width = 60,
        content = {
          { "name", zindex = 10 },
          -- {
          --   "symlink_target",
          --   zindex = 10,
          --   highlight = "NeoTreeSymbolicLinkTarget",
          -- },
          { "clipboard", zindex = 10 },
          { "diagnostics", errors_only = true, zindex = 20, align = "right" },
        },
      },
    },
    file = {
      { "indent" },
      { "icon" },
      {
        "container",
        width = "100%",
        right_padding = 1,
        --max_width = 60,
        content = {
          {
            "name",
            use_git_status_colors = true,
            zindex = 10,
          },
          -- {
          --   "symlink_target",
          --   zindex = 10,
          --   highlight = "NeoTreeSymbolicLinkTarget",
          -- },
          { "clipboard", zindex = 10 },
          { "bufnr", zindex = 10 },
          { "modified", zindex = 20, align = "right" },
          { "diagnostics", zindex = 20, align = "right" },
          { "git_status", zindex = 20, align = "right" },
        },
      },
    },
  },
  nesting_rules = {},
  filesystem = {
    bind_to_cwd = true,
    window = {
      mappings = {
        ["H"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        --["/"] = "filter_as_you_type", -- this was the default until v1.28
        ["f"] = "filter_on_submit",
        ["<C-x>"] = "clear_filter",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
      },
    },
    filtered_items = {
      visible = true, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = true,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        --"node_modules"
      },
      never_show = { -- remains hidden even if visible is toggled to true
        --".DS_Store",
        --"thumbs.db"
      },
    },
    follow_current_file = true, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_current",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
    -- instead of relying on nvim autocmd events.
  },
  buffers = {
    show_unloaded = true,
    window = {
      mappings = {
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["bd"] = "buffer_delete",
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

M.setup = function()
  vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

  require("neo-tree").setup(M.config)

  local Key = utils.Key
  local Group = utils.Group
  utils.load({
    Key("n", "<Leader>e", "<cmd>Neotree filesystem reveal<cr>", "Explorer"),
    Key("n", "<Leader>E", "<cmd>Neotree toggle<cr>", "Explorer"),
    Key("n", "<Leader>vg", "<cmd>Neotree git_status left<cr>", "Git Status"),
    Key("n", "<Leader>vG", "<cmd>Neotree git_status float<cr>", "Git Status"),
    Key("n", "<Leader>vb", "<cmd>Neotree buffers left<cr>", "Opened Files"),
    Key("n", "<Leader>vB", "<cmd>Neotree buffers float<cr>", "Opened Files"),
    Group("UserNeoTreeTabKey"):cmd("FileType", "neo-tree", function()
      Key("n", "<Tab>", "<C-w>l"):buffer(0):set()
    end),
  })
end

return M
