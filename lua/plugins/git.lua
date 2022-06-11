local M = {}

M.packers = {
  {
    "lewis6991/gitsigns.nvim",
    module = "gitsigns",
    config = function()
      require("plugins.git").setup_gitsigns()
    end,
    event = "BufRead",
    disable = false,
  },
  {
    "sindrets/diffview.nvim",
    module = "diffview",
    config = function()
      require("plugins.git").setup_diffview()
    end,
    event = "BufRead",
    disable = false,
  },
}

M.setup_diffview = function()
  local diffview = require("diffview")
  diffview.setup({
    enhanced_diff_hl = true,
    key_bindings = {
      file_panel = { q = "<Cmd>DiffviewClose<CR>" },
      view = { q = "<Cmd>DiffviewClose<CR>" },
      file_history_panel = { q = "<Cmd>DiffviewClose<CR>" },
    },
  })
  utils.Key("n", "<Leader>gd", "<cmd>DiffviewOpen<cr>", "Diff HEAD")
  utils.Key("n", "<Leader>gD", "<cmd>DiffviewOpen -uno -- %<cr>", "Diff Current File")
  utils.Key("n", "<Leader>gh", "<cmd>DiffviewFileHistory<cr>", "View File History")
end

M.setup_gitsigns = function()
  local gitsigns = require("gitsigns")
  gitsigns.setup({
    signs = {
      add = {
        hl = "GitSignsAdd",
        text = "▎",
        numhl = "GitSignsAddNr",
        linehl = "GitSignsAddLn",
      },
      change = {
        hl = "GitSignsChange",
        text = "▎",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
      delete = {
        hl = "GitSignsDelete",
        text = "",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      topdelete = {
        hl = "GitSignsDelete",
        text = "",
        numhl = "GitSignsDeleteNr",
        linehl = "GitSignsDeleteLn",
      },
      changedelete = {
        hl = "GitSignsChange",
        text = "▎",
        numhl = "GitSignsChangeNr",
        linehl = "GitSignsChangeLn",
      },
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 6,
    update_debounce = 200,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
      -- Options passed to nvim_open_win
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    yadm = {
      enable = false,
    },
    on_attach = function()
      -- local gitsigns = package.loaded.gitsigns
      utils.Key("n", "]g", gitsigns.next_hunk, "Next Git Hunk")
      utils.Key("n", "[g", gitsigns.prev_hunk, "Previous Git Hunk")
      utils.load_wk({
        name = "Git",
        l = { gitsigns.blame_line, "Blame" },
        p = { gitsigns.preview_hunk, "Preview Hunk" },
        r = { gitsigns.reset_hunk, "Reset Hunk" },
        R = { gitsigns.reset_buffer, "Reset Buffer" },
        s = { gitsigns.stage_hunk, "Stage Hunk" },
        S = { gitsigns.stage_buffer, "Stage Buffer" },
        u = { gitsigns.undo_stage_hunk, "Undo Stage Hunk" },
        f = { "<cmd>Telescope git_status<cr>", "Open Changed File" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout Branch" },
        B = { "<cmd>Telescope git_stash<cr>", "Checkout Stash" },
        c = { "<cmd>Telescope git_commits<cr>", "Checkout Commit" },
        C = { "<cmd>Telescope git_bcommits<cr>", "Checkout Current File" },
      }, { prefix = "<Leader>g", mode = "n" })
      utils.load_wk({
        name = "GitSigns",
        s = { "<cmd>Gitsigns toggle_signcolumn<cr>", "Toggle Signcolumn" },
        n = { "<cmd>Gitsigns toggle_numhl<cr>", "Toggle Numhl" },
        l = { "<cmd>Gitsigns toggle_linehl<cr>", "Toggle Linehl" },
        w = { "<cmd>Gitsigns toggle_word_diff<cr>", "Toggle Word Diff" },
        b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle Line Blame" },
      }, { prefix = "yog", mode = "n" })
    end,
  })
end

return M
