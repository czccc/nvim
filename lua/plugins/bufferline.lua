local M = {}

M.packers = {
  {
    "akinsho/bufferline.nvim",
    event = "BufWinEnter",
    disable = false,
    config = function()
      require("plugins.bufferline").setup()
    end,
  },
  {
    "ojroques/nvim-bufdel",
    event = "BufWinEnter",
    disable = false,
    config = function()
      require("bufdel").setup({
        next = "alternate", -- or 'alternate'
        quit = false,
      })
    end,
  },
}

local function is_ft(b, ft)
  return vim.bo[b].filetype == ft
end

local function diagnostics_indicator(_, _, diagnostics)
  local result = {}
  local symbols = { error = " ", warning = " ", info = " " }
  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. count)
    end
  end
  result = table.concat(result, " ")
  return #result > 0 and result or ""
end

local function custom_filter(buf, buf_nums)
  local logs = vim.tbl_filter(function(b)
    return is_ft(b, "log")
  end, buf_nums)
  if vim.tbl_isempty(logs) then
    return true
  end
  local tab_num = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr("$")
  local is_log = is_ft(buf, "log")
  if last_tab == 1 then
    return true
  end
  -- only show log buffers in secondary tabs
  return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
end

M.config = {
  keymap = {
    ["n"] = {
      ["<S-x>"] = ":BufDel<CR>",
      ["<TAB>"] = ":BufferLineCycleNext<CR>",
      ["<S-TAB>"] = ":BufferLineCyclePrev<CR>",
      ["<A-<>"] = ":BufferLineMovePrev<CR>",
      ["<A->>"] = ":BufferLineMoveNext<CR>",
    },
  },
  highlights = {
    background = {
      gui = "italic",
    },
    buffer_selected = {
      gui = "bold",
    },
  },
  options = {
    numbers = "none", -- can be "none" | "ordinal" | "buffer_id" | "both" | function
    close_command = "BufDel %d", -- can be a string | function, see "Mouse actions"
    right_mouse_command = "vert sbuffer %d", -- can be a string | function, see "Mouse actions"
    left_mouse_command = "buffer %d", -- can be a string | function, see "Mouse actions"
    middle_mouse_command = nil, -- can be a string | function, see "Mouse actions"
    -- NOTE: this plugin is designed with this icon in mind,
    -- and so changing this is NOT recommended, this is intended
    -- as an escape hatch for people who cannot bear it for whatever reason
    indicator_icon = "▎",
    buffer_close_icon = "",
    modified_icon = "●",
    close_icon = "",
    left_trunc_marker = "",
    right_trunc_marker = "",
    --- name_formatter can be used to change the buffer's label in the bufferline.
    --- Please note some names can/will break the
    --- bufferline so use this at your discretion knowing that it has
    --- some limitations that will *NOT* be fixed.
    name_formatter = function(buf) -- buf contains a "name", "path" and "bufnr"
      -- remove extension from markdown files for example
      if buf.name:match("%.md") then
        return vim.fn.fnamemodify(buf.name, ":t:r")
      end
    end,
    max_name_length = 18,
    max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
    tab_size = 18,
    diagnostics = "nvim_lsp",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = diagnostics_indicator,
    -- NOTE: this will be called a lot so don't do any heavy processing here
    custom_filter = custom_filter,
    offsets = {
      {
        filetype = "undotree",
        text = "Undotree",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "neo-tree",
        text = "Explorer",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "NvimTree",
        text = "Explorer",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "DiffviewFiles",
        text = "Diff View",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "flutterToolsOutline",
        text = "Flutter Outline",
        highlight = "PanelHeading",
      },
      {
        filetype = "packer",
        text = "Packer",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "Outline",
        text = "Symbol Outline",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "SidebarNvim",
        text = "Sidebar",
        highlight = "PanelHeading",
        padding = 1,
      },
    },
    show_buffer_icons = true, -- disable filetype icons for buffers
    show_buffer_close_icons = true,
    show_close_icon = false,
    show_tab_indicators = true,
    persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
    -- can also be a table containing 2 custom separators
    -- [focused and unfocused]. eg: { '|', '|' }
    separator_style = "thin",
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    sort_by = "id",
  },
}

M.setup = function()
  require("core.keymap").load(M.config.keymap)
  ---@diagnostic disable-next-line: different-requires
  require("bufferline").setup({
    options = M.config.options,
    highlights = M.config.highlights,
  })

  local LeaderKey = require("utils.key").PrefixModeKey("<Leader>", "n")
  local LeaderbKey = require("utils.key").PrefixModeKey("<Leader>b", "n")
  require("utils.key").load({
    LeaderKey("c", "<cmd>BufDel<cr>"):desc("Close Buffer"),

    LeaderbKey(""):group("Buffers"),
    LeaderbKey("b", require("plugins.telescope").find_buffers):desc("Find Buffer"),
    LeaderbKey("c", "<cmd>BufDel<cr>"):desc("Close Current"),
    LeaderbKey("f", "<cmd>b#<cr>"):desc("Previous"),
    LeaderbKey("h", "<cmd>BufferLineCloseLeft<cr>"):desc("Close To Left"),
    LeaderbKey("l", "<cmd>BufferLineCloseRight<cr>"):desc("Close To Right"),
    LeaderbKey("j", "<cmd>BufferLineMovePrev<cr>"):desc("Move To Left"),
    LeaderbKey("k", "<cmd>BufferLineMoveNext<cr>"):desc("Move To Right"),
    LeaderbKey("p", "<cmd>BufferLinePick<cr>"):desc("Buffer Pick"),
    LeaderbKey("d", "<cmd>BufferLineSortByDirectory<cr>"):desc("Sort By Directory"),
    LeaderbKey("L", "<cmd>BufferLineSortByExtension<cr>"):desc("Sort By Extension"),
    LeaderbKey("n", "<cmd>BufferLineSortByTabs<cr>"):desc("Sort By Tab"),

    LeaderbKey("g"):group("Buffer Goto"),
    LeaderbKey("g1", "<cmd>BufferLineGoToBuffer 1<cr>"):desc("Buffer Goto 1"),
    LeaderbKey("g2", "<cmd>BufferLineGoToBuffer 2<cr>"):desc("Buffer Goto 2"),
    LeaderbKey("g3", "<cmd>BufferLineGoToBuffer 3<cr>"):desc("Buffer Goto 3"),
    LeaderbKey("g4", "<cmd>BufferLineGoToBuffer 4<cr>"):desc("Buffer Goto 4"),
    LeaderbKey("g5", "<cmd>BufferLineGoToBuffer 5<cr>"):desc("Buffer Goto 5"),
    LeaderbKey("g6", "<cmd>BufferLineGoToBuffer 6<cr>"):desc("Buffer Goto 6"),
    LeaderbKey("g7", "<cmd>BufferLineGoToBuffer 7<cr>"):desc("Buffer Goto 7"),
    LeaderbKey("g8", "<cmd>BufferLineGoToBuffer 8<cr>"):desc("Buffer Goto 8"),
    LeaderbKey("g9", "<cmd>BufferLineGoToBuffer 9<cr>"):desc("Buffer Goto 9"),
  })
end

return M
