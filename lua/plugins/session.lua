local M = {}

M.packers = {
  {
    "Shatur/neovim-session-manager",
    config = function()
      require("plugins.session").setup_session_manager()
    end,
    disable = false,
  },
}

M.setup_session_manager = function()
  local Path = require("plenary.path")
  local session_manager = require("session_manager")
  session_manager.setup({
    sessions_dir = Path:new(vim.fn.stdpath("data"), "sessions"), -- The directory where the session files will be saved.
    path_replacer = "__", -- The character to which the path separator will be replaced for session files.
    colon_replacer = "++", -- The character to which the colon symbol will be replaced for session files.
    autoload_mode = require("session_manager.config").AutoloadMode.Disabled, -- Define what to do when Neovim is started without arguments. Possible values: Disabled, CurrentDir, LastSession
    autosave_last_session = true, -- Automatically save last session on exit and on session switch.
    autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
    autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
      "gitcommit",
      "Outline",
      "NvimTree",
      "neo-tree",
      "nofile",
    },
    autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
    max_path_length = 80, -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all.
  })

  utils.Key("n", "<Leader>sp", session_manager.load_session, "Projects")
  utils.load_wk({
    name = "Sessions",
    s = { session_manager.save_current_session, "Save" },
    c = { session_manager.load_current_dir_session, "Restore CurDir" },
    l = { session_manager.load_last_session, "Restore Last" },
    A = { session_manager.autosave_session, "Auto Save" },
    a = { session_manager.autoload_session, "Auto Restore" },
    d = { session_manager.delete_session, "Delete" },
    p = { session_manager.load_session, "List" },
  }, { prefix = "<Leader>S", mode = "n" })
  utils.Group("UserSessionRestoreExplorer", { "User", "SessionLoadPost", M.restore_explorer })
  -- utils.Group("UserSessionSaveOnLeave", { "ExitPre", "*", session_manager.autosave_session })
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
  local neotree_status_ok, _ = pcall(require, "neo-tree.command")
  if neotree_status_ok then
    -- pcall(neotree.execute, { action = "close" })
    -- pcall(neotree.execute, { action = "focus" })
    pcall(vim.cmd, [[ Neotree filesystem show reveal ]])
    pcall(vim.cmd, [[ wincmd = ]])
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
