local M = {}
local path = require("utils.path")

M.packers = {
  {
    "natecraddock/workspaces.nvim",
    config = function()
      require("plugins.workspaces").setup_workspaces()
    end,
    disable = true,
  },
  {
    "natecraddock/sessions.nvim",
    config = function()
      require("plugins.workspaces").setup_sessions()
    end,
    disable = true,
  },
  {
    "rmagatti/auto-session",
    config = function()
      require("plugins.session").setup_autosession()
    end,
    disable = true,
  },
  {
    "jedrzejboczar/possession.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.session").setup_possession()
    end,
    disable = true,
  },
}

M.setup_workspaces = function()
  require("workspaces").setup({
    -- path to a file to store workspaces data in
    -- on a unix system this would be ~/.local/share/nvim/workspaces
    path = path.join(vim.fn.stdpath("data"), "workspaces"),

    -- to change directory for all of nvim (:cd) or only for the current window (:lcd)
    -- if you are unsure, you likely want this to be true.
    global_cd = true,

    -- sort the list of workspaces by name after loading from the workspaces path.
    sort = true,

    -- enable info-level notifications after adding or removing a workspace
    notify_info = true,

    -- lists of hooks to run after specific actions
    -- hooks can be a lua function or a vim command (string)
    -- if only one hook is needed, the list may be omitted
    hooks = {
      add = {},
      remove = {},
      open_pre = {
        -- -- delete all buffers (does not save changes)
        -- "silent %bdelete!",
        -- "SessionManager save_current_session",
      },
      open = {
        "SessionManager load_current_dir_session",
        M.restore_explorer(),
      },
    },
  })
  require("telescope").load_extension("workspaces")
  local wk = require("plugins.which_key")
  wk.config.nmappings["s"]["p"] = { ":lua require('plugins.workspaces').workspaces()<cr>", "workspaces" }
end

M.setup_sessions = function()
  require("sessions").setup({
    events = { "VimLeavePre" },
    session_filepath = ".nvim/session",
  })
end

function M.workspaces()
  local opts = require("plugins.telescope").dropdown_opts()
  opts.initial_mode = "normal"
  require("telescope").extensions.workspaces.workspaces(opts)
end

M.setup_autosession = function()
  require("auto-session").setup({
    log_level = "error",
    auto_session_enable_last_session = false,
    auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
    auto_session_create_enabled = false,
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_suppress_dirs = nil,
    -- the configs below are lua only
    bypass_session_save_file_types = { "Outline", "NvimTree", "neo-tree" },
    pre_save_cmds = { M.close_explorer },
    post_restore_cmds = { M.restore_explorer },
  })
  require("plugins.which_key").register({
    ["u"] = {
      ["s"] = {
        name = "+Session",
        s = { "<cmd>SaveSession<cr>", "SaveSession" },
        r = { "<cmd>RestoreSession<cr>", "RestoreSession" },
        d = { "<cmd>DeleteSession<cr>", "DeleteSession" },
      },
    },
  })
end

M.setup_possession = function()
  -- local Path = require("plenary").Path
  ---@diagnostic disable-next-line: different-requires
  require("possession").setup({
    -- session_dir = (Path:new(vim.fn.stdpath "data") / "possession"):absolute(),
    silent = false,
    load_silent = true,
    debug = false,
    commands = {
      save = "PossessionSave",
      load = "PossessionLoad",
      delete = "PossessionDelete",
      show = "PossessionShow",
      list = "PossessionList",
      migrate = "PossessionMigrate",
    },
    -- hooks = {
    --   before_save = function(name)
    --     return {}
    --   end,
    --   after_save = function(name, user_data, aborted) end,
    --   before_load = function(name, user_data)
    --     return user_data
    --   end,
    --   after_load = function(name, user_data) end,
    -- },
    plugins = {
      close_windows = {
        hooks = { "before_save", "before_load" },
        preserve_layout = true, -- or fun(win): boolean
        match = {
          floating = true,
          buftype = {},
          filetype = {},
          custom = false, -- or fun(win): boolean
        },
      },
      delete_hidden_buffers = {
        hooks = {
          "before_load",
          vim.o.sessionoptions:match("buffer") and "before_save",
        },
        force = false,
      },
      nvim_tree = true,
      tabby = true,
    },
  })
  require("telescope").load_extension("possession")
end

function M.close_explorer()
  local status_ok, nvim_tree = pcall(require, "nvim-tree")
  if status_ok then
    pcall(nvim_tree.change_dir, vim.fn.getcwd())
    pcall(nvim_tree.toggle, false, false)
    -- require("nvim-tree.actions.reloaders").reload_explorer()
  end
  local neotree_status_ok, neotree = pcall(require, "neo-tree.command")
  if neotree_status_ok then
    pcall(neotree.execute, { action = "close" })
    -- pcall(vim.cmd [[tabdo Neotree close]])
  end
  pcall(vim.cmd, [[tabdo SymbolsOutlineClose]])
  pcall(vim.cmd, [[tabdo SidebarNvimClose]])
end

function M.restore_explorer()
  ---@diagnostic disable-next-line: unused-local
  local neotree_status_ok, _ = pcall(require, "neo-tree.command")
  if neotree_status_ok then
    -- pcall(neotree.execute, { action = "close" })
    -- pcall(neotree.execute, { action = "focus" })
    pcall(vim.cmd, [[ Neotree filesystem show reveal ]])
    pcall(vim.cmd, vim.api.nvim_replace_termcodes("normal <C-w>=", true, true, true))
    return
  end
  local status_ok, nvim_tree = pcall(require, "nvim-tree")
  if status_ok then
    pcall(nvim_tree.change_dir, vim.fn.getcwd())
    pcall(nvim_tree.toggle, false, false)
    -- require("nvim-tree.actions.reloaders").reload_explorer()
    return
  end
end

return M
