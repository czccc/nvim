local M = {}

M.packer = {
  "goolord/alpha-nvim",
  config = function()
    require("plugins.alpha").setup()
  end,
  disable = false,
}

local make_header = function()
  return {
    type = "text",
    val = require("utils.banners").dashboard(),
    opts = {
      position = "center",
      hl = "Type",
      wrap = "overflow",
    },
  }
end
local make_footer = function()
  return {
    type = "text",
    val = require("alpha.fortune")(),
    opts = {
      position = "center",
      hl = "Number",
    },
  }
end
local function make_infos()
  local plugins = #vim.tbl_keys(packer_plugins)
  local v = vim.version()
  local infos = {}
  table.insert(infos, os.date(" %Y-%m-%d"))
  table.insert(infos, os.date(" %H:%M:%S"))
  table.insert(infos, string.format(" v%d.%d.%d", v.major, v.minor, v.patch))
  table.insert(infos, string.format(" %d", plugins))
  local infos_str = table.concat(infos, "     ")
  return {
    type = "text",
    val = infos_str,
    opts = {
      position = "center",
      hl = "Number",
    },
  }
end

local function make_sessions()
  local function shorten_path(filename)
    if #filename > 35 then
      filename = require("plenary.path"):new(filename):shorten()
    end
    if #filename > 35 then
      filename = "..." .. string.sub(filename, -34, -1)
    end
    return filename
  end

  local dashboard = require("alpha.themes.dashboard")
  local session_list = require("session_manager.utils").get_sessions()
  local last_session = require("session_manager.utils").get_last_session_filename()

  local buttons = {
    type = "group",
    val = {
      dashboard.button("p", "  > Sessions Pick", ":SessionManager load_session<CR>"),
      dashboard.button("c", "  > Restore Current Session", ":SessionManager load_current_dir_session<CR>"),
      dashboard.button("l", "  > Restore Last Session", ":SessionManager load_last_session<CR>"),
    },
    opts = {
      spacing = 1,
    },
  }
  local idx = 0
  for _, session in ipairs(session_list) do
    idx = idx + 1
    if idx > 9 then
      return buttons
    end
    local desc = " "
    if session.dir.filename == vim.loop.cwd() then
      desc = desc .. "(c)"
    end
    if session.filename == last_session then
      desc = desc .. "(l)"
    end
    local but = dashboard.button(
      string.format("%d", idx),
      "  > " .. shorten_path(session.dir.filename) .. desc,
      string.format(":lua require('session_manager.utils').load_session('%s')<CR>", session.filename)
    )
    table.insert(buttons.val, but)
  end

  return buttons
end

function M.setup()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")
  local header = make_header()
  local footer = make_footer()
  local infos = make_infos()
  local sessions = make_sessions()

  local buttons = {
    type = "group",
    val = {
      dashboard.button("e", "  > File Explore", ":Neotree filesystem<CR>"),
      dashboard.button("E", "  > New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("s", "  > Find ...", ":Telescope<CR>"),
      dashboard.button("f", "  > Find file", ":Telescope find_files<CR>"),
      dashboard.button("r", "  > Recent Files", ":Telescope frecency<CR>"),
      dashboard.button("q", "  > Quit NVIM", ":q<CR>"),
    },
    opts = {
      spacing = 1,
    },
  }

  local config = {
    layout = {
      { type = "padding", val = 2 },
      header,
      { type = "padding", val = 2 },
      buttons,
      { type = "padding", val = 2 },
      -- {
      --   type = "text",
      --   val = "Sessions:",
      --   opts = {
      --     position = "center",
      --     hl = "Number",
      --     spacing = 1,
      --   },
      -- },
      sessions,
      { type = "padding", val = 2 },
      infos,
      footer,
    },
    opts = {
      margin = 5,
    },
  }

  alpha.setup(config)
  -- utils.Group("UserAlphaSetting", { "FileType", "alpha", "setlocal nofoldenable" })
  utils.Key("n", "<Leader>ua", "<cmd>Alpha<cr>", "Dashboard")
end

return M
