local M = {}

M.packer = {
  "rcarriga/nvim-notify",
  event = "VimEnter",
  config = function()
    require("plugins.notify").setup()
  end,
}

M.config = {
  setup = {
    ---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
    stages = "slide",

    ---@usage Function called when a new window is opened, use for changing win settings/config
    on_open = nil,

    ---@usage Function called when a window is closed
    on_close = nil,

    ---@usage timeout for notifications in ms, default 5000
    timeout = 5000,

    -- Render function for notifications. See notify-render()
    render = "default",

    ---@usage highlight behind the window for stages that change opacity
    background_colour = "Normal",

    ---@usage minimum width for notification windows
    minimum_width = 50,

    ---@usage Icons for the different levels
    icons = {
      ERROR = "",
      WARN = "",
      INFO = "",
      DEBUG = "",
      TRACE = "",
    },
  },
}

M.setup = function()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  local status_ok, notify = pcall(require, "notify")
  if not status_ok then
    print("notify not loaded")
    return
  end

  notify.setup(M.config.setup)
  vim.notify = notify

  pcall(function()
    require("telescope").load_extension("notify")
    utils.Key("n", "<Leader>sn", "<cmd>Telescope notify<cr>", "Notify")
  end)
end

return M
