local M = {}

M.packer = {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("plugins.gitsigns").setup()
  end,
  event = "BufRead",
  disable = false,
}

M.config = {
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
  numhl = false,
  linehl = false,
  keymaps = {
    -- Default keymap options
    noremap = true,
    buffer = true,
  },
  signcolumn = true,
  word_diff = false,
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  current_line_blame_formatter_opts = {
    relative_time = false,
  },
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = "rounded",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },
  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },
  sign_priority = 6,
  update_debounce = 200,
  status_formatter = nil, -- Use default
}

M.setup = function()
  local gitsigns = require("gitsigns")
  gitsigns.setup(M.config)

  local Key = require("utils.key").Key
  require("utils.key").load({
    Key("n", "]g", gitsigns.next_hunk):desc("Next Git Hunk"),
    Key("n", "[g", gitsigns.prev_hunk):desc("Previous Git Hunk"),

    Key("n", "<Leader>g"):group("Git"),
    Key("n", "<Leader>gj", gitsigns.next_hunk):desc("Next Hunk"),
    Key("n", "<Leader>gk", gitsigns.prev_hunk):desc("Prev Hunk"),
    Key("n", "<Leader>gl", gitsigns.blame_line):desc("Blame"),
    Key("n", "<Leader>gp", gitsigns.preview_hunk):desc("Preview Hunk"),
    Key("n", "<Leader>gr", gitsigns.reset_hunk):desc("Reset Hunk"),
    Key("n", "<Leader>gR", gitsigns.reset_buffer):desc("Reset Buffer"),
    Key("n", "<Leader>gs", gitsigns.stage_hunk):desc("Stage Hunk"),
    Key("n", "<Leader>gu", gitsigns.undo_stage_hunk):desc("Undo Stage Hunk"),

    Key("n", "<Leader>go", "<cmd>Telescope git_status<cr>"):desc("Open changed file"),
    Key("n", "<Leader>gb", "<cmd>Telescope git_branches<cr>"):desc("Checkout branch"),
    Key("n", "<Leader>gv", "<cmd>Telescope git_commits<cr>"):desc("Checkout commit"),
    Key("n", "<Leader>gC", "<cmd>Telescope git_bcommits<cr>"):desc("Checkout commit(for current file)"),
    Key("n", "<Leader>gd", "<cmd>Telescope git_bcommits<cr>"):desc("Checkout commit(for current file)"),

    Key("n", "<Leader>gt"):group("Toggle"),
    Key("n", "<Leader>gts", "<cmd>Gitsigns toggle_signcolumn<cr>"):desc("Toggle Signcolumn"),
    Key("n", "<Leader>gtn", "<cmd>Gitsigns toggle_numhl<cr>"):desc("Toggle Numhl"),
    Key("n", "<Leader>gtl", "<cmd>Gitsigns toggle_linehl<cr>"):desc("Toggle Linehl"),
    Key("n", "<Leader>gtw", "<cmd>Gitsigns toggle_word_diff<cr>"):desc("Toggle Word Diff"),
    Key("n", "<Leader>gtb", "<cmd>Gitsigns toggle_current_line_blame<cr>"):desc("Toggle Line Blame"),
  })
end

return M
