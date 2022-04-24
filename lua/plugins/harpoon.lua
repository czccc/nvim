local M = {}

M.packer = {
  "ThePrimeagen/harpoon",
  config = function()
    require("plugins.harpoon").setup()
  end,
}

M.setup = function()
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
  local utils = require("utils")
  -- utils.Key("n", "<leader>fm", require("harpoon.ui").toggle_quick_menu, "Harpoon"):set()
  utils.Key("n", "<leader>fh", "<cmd>Telescope harpoon marks theme=dropdown<cr>", "Harpoon"):set()
  utils.Key("n", "<leader>fH", require("harpoon.mark").add_file, "Harpoon Add"):set()
  utils.Key("n", "<leader>fn", require("harpoon.ui").nav_next, "Harpoon Next"):set()
  utils.Key("n", "<leader>fp", require("harpoon.ui").nav_prev, "Harpoon Previous"):set()
end

return M
