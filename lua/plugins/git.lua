local M = {}

M.packers = {
  {
    "lewis6991/gitsigns.nvim",
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
  utils.Key("n", "<Leader>gd", "<cmd>DiffviewOpen<cr>", "Diff HEAD"):set()
  utils.Key("n", "<Leader>gD", "<cmd>DiffviewOpen -uno -- %<cr>", "Diff Current File"):set()
  utils.Key("n", "<Leader>gh", "<cmd>DiffviewFileHistory<cr>", "View File History"):set()
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
      local Key = utils.Key
      utils.load({
        Key("n", "]g", gitsigns.next_hunk, "Next Git Hunk"),
        Key("n", "[g", gitsigns.prev_hunk, "Previous Git Hunk"),

        Key("n", "<Leader>g"):group("Git"),
        Key("n", "<Leader>gl", gitsigns.blame_line, "Blame"),
        Key("n", "<Leader>gp", gitsigns.preview_hunk, "Preview Hunk"),
        Key("n", "<Leader>gr", gitsigns.reset_hunk, "Reset Hunk"),
        Key("n", "<Leader>gR", gitsigns.reset_buffer, "Reset Buffer"),
        Key("n", "<Leader>gs", gitsigns.stage_hunk, "Stage Hunk"),
        Key("n", "<Leader>gS", gitsigns.stage_buffer, "Stage Buffer"),
        Key("n", "<Leader>gu", gitsigns.undo_stage_hunk, "Undo Stage Hunk"),

        Key("n", "<Leader>gf", "<cmd>Telescope git_status<cr>", "Open Changed File"),
        Key("n", "<Leader>gb", "<cmd>Telescope git_branches<cr>", "Checkout Branch"),
        Key("n", "<Leader>gB", "<cmd>Telescope git_stash<cr>", "Checkout Stash"),
        Key("n", "<Leader>gc", "<cmd>Telescope git_commits<cr>", "Checkout Commit"),
        Key("n", "<Leader>gC", "<cmd>Telescope git_bcommits<cr>", "Checkout Current File)"),

        Key("n", "yog"):group("Gitsigns"),
        Key("n", "yogs", "<cmd>Gitsigns toggle_signcolumn<cr>", "Toggle Signcolumn"),
        Key("n", "yogn", "<cmd>Gitsigns toggle_numhl<cr>", "Toggle Numhl"),
        Key("n", "yogl", "<cmd>Gitsigns toggle_linehl<cr>", "Toggle Linehl"),
        Key("n", "yogw", "<cmd>Gitsigns toggle_word_diff<cr>", "Toggle Word Diff"),
        Key("n", "yogb", "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle Line Blame"),
      })
    end,
  })
end

return M
