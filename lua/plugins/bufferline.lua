local M = {}

M.packers = {
  {
    "akinsho/bufferline.nvim",
    event = "BufWinEnter",
    disable = false,
    config = function()
      require("plugins.bufferline").setup()
    end,
    wants = {
      "nvim-web-devicons",
      "nvim-bufdel",
    },
    requires = {
      "nvim-web-devicons",
      {
        "ojroques/nvim-bufdel",
        event = "BufWinEnter",
        config = function()
          require("bufdel").setup({
            next = "alternate", -- or 'alternate'
            quit = false,
          })
        end,
      },
    },
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
  highlights = {
    background = {
      italic = true,
    },
    buffer_selected = {
      bold = true,
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
    indicator = {
      style = "icon",
      icon = "▎",
    },
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
        highlight = "NeoTreeNormal",
        padding = 1,
        --[[ separator = true, -- use a "true" to enable the default, or set your own character ]]
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
      {
        filetype = "neotest-summary",
        text = "Test Summary",
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
    sort_by = "insert_after_current",
    -- custom_areas = {
    --   right = function()
    --     local result = {}
    --     local seve = vim.diagnostic.severity
    --     local error = #vim.diagnostic.get(0, { severity = seve.ERROR })
    --     local warning = #vim.diagnostic.get(0, { severity = seve.WARN })
    --     local info = #vim.diagnostic.get(0, { severity = seve.INFO })
    --     local hint = #vim.diagnostic.get(0, { severity = seve.HINT })

    --     if error ~= 0 then
    --       table.insert(result, { text = "  " .. error, guifg = "#EC5241" })
    --     end

    --     if warning ~= 0 then
    --       table.insert(result, { text = "  " .. warning, guifg = "#EFB839" })
    --     end

    --     if hint ~= 0 then
    --       table.insert(result, { text = "  " .. hint, guifg = "#A3BA5E" })
    --     end

    --     if info ~= 0 then
    --       table.insert(result, { text = "  " .. info, guifg = "#7EA9A7" })
    --     end
    --     return result
    --   end,
    -- },
  },
}

M.setup = function()
  require("bufferline").setup({
    options = M.config.options,
    highlights = M.config.highlights,
  })

  utils.Key("n", "<S-x>", "<cmd>BufDel<cr>", "BufDel")
  utils.Key("n", "<Leader>c", "<cmd>BufDel<cr>", "Close Buffer")
  utils.Key("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", "BufferLineCycleNext")
  utils.Key("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", "BufferLineCyclePrev")
  utils.Key("n", "]b", "<cmd>BufferLineCycleNext<cr>", "Next Buffer")
  utils.Key("n", "[b", "<cmd>BufferLineCyclePrev<cr>", "Previous Buffer")

  utils.load_wk({
    name = "Buffers",
    b = { require("plugins.telescope").find_buffers, "Find Buffer" },
    c = { "<cmd>BufDel<cr>", "Close Current" },
    C = { "<cmd>BufferLinePickClose<cr>", "Buffer Pick Close" },
    f = { "<cmd>b#<cr>", "Previous" },
    h = { "<cmd>BufferLineCloseLeft<cr>", "Close To Left" },
    l = { "<cmd>BufferLineCloseRight<cr>", "Close To Right" },
    j = { "<cmd>BufferLineMovePrev<cr>", "Move To Left" },
    k = { "<cmd>BufferLineMoveNext<cr>", "Move To Right" },
    p = { "<cmd>BufferLinePick<cr>", "Buffer Pick" },
    P = { "<cmd>BufferLineTogglePin<cr>", "Buffer Pin" },
    d = { "<cmd>BufferLineSortByDirectory<cr>", "Sort By Directory" },
    e = { "<cmd>BufferLineSortByExtension<cr>", "Sort By Extension" },
    t = { "<cmd>BufferLineSortByTabs<cr>", "Sort By Tab" },

    ["1"] = { "<cmd>BufferLineGoToBuffer 1<cr>", "Buffer Goto 1" },
    ["2"] = { "<cmd>BufferLineGoToBuffer 2<cr>", "Buffer Goto 2" },
    ["3"] = { "<cmd>BufferLineGoToBuffer 3<cr>", "Buffer Goto 3" },
    ["4"] = { "<cmd>BufferLineGoToBuffer 4<cr>", "Buffer Goto 4" },
    ["5"] = { "<cmd>BufferLineGoToBuffer 5<cr>", "Buffer Goto 5" },
    ["6"] = { "<cmd>BufferLineGoToBuffer 6<cr>", "Buffer Goto 6" },
    ["7"] = { "<cmd>BufferLineGoToBuffer 7<cr>", "Buffer Goto 7" },
    ["8"] = { "<cmd>BufferLineGoToBuffer 8<cr>", "Buffer Goto 8" },
    ["9"] = { "<cmd>BufferLineGoToBuffer 9<cr>", "Buffer Goto 9" },
  }, { prefix = "<Leader>b", mode = "n" })
end

return M
