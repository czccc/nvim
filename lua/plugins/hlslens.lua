local M = {}

M.packer = {
  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("plugins.hlslens").setup_hlslens()
    end,
    event = "BufRead",
  },
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("plugins.hlslens").setup_scrollbar()
    end,
    after = { "nvim-hlslens" },
    event = "BufRead",
  },
}

M.set_hlslens_keymaps = function()
  utils.Key(
    "n",
    "n",
    "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
    "Search Next"
  )
  utils.Key(
    "n",
    "N",
    "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
    "Search Previous"
  )
  utils.Key("n", "*", "*<Cmd>lua require('hlslens').start()<CR>", "Search CurWord Forward")
  utils.Key("n", "#", "#<Cmd>lua require('hlslens').start()<CR>", "Search CurWord Backward")
  utils.Key("n", "g*", "g*<Cmd>lua require('hlslens').start()<CR>", "Fuzzy CurWord Forward")
  utils.Key("n", "g#", "g#<Cmd>lua require('hlslens').start()<CR>", "Fuzzy CurWord Backward")
end

M.setup_hlslens = function()
  local status_ok, hlslens = pcall(require, "hlslens")
  if not status_ok then
    return
  end
  local opts = {
    auto_enable = true,
    calm_down = true,
    enable_incsearch = true,
    nearest_only = false,
    override_lens = function(render, plist, nearest, idx, r_idx)
      local sfw = vim.v.searchforward == 1
      local indicator, text, chunks
      local abs_r_idx = math.abs(r_idx)
      if abs_r_idx > 1 then
        indicator = string.format("%d%s", abs_r_idx, sfw ~= (r_idx > 1) and "" or "")
      elseif abs_r_idx == 1 then
        indicator = sfw ~= (r_idx == 1) and "" or ""
      else
        indicator = ""
      end

      local lnum, col = table.unpack(plist[idx])
      if nearest then
        local cnt = #plist
        if indicator ~= "" then
          text = string.format("[%s %d/%d]", indicator, idx, cnt)
        else
          text = string.format("[%d/%d]", idx, cnt)
        end
        chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
      else
        text = string.format("[%s %d]", indicator, idx)
        chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
      end
      render.set_virt(0, lnum - 1, col - 1, chunks, nearest)
    end,
  }

  hlslens.setup(opts)
  require("plugins.hlslens").set_hlslens_keymaps()
  -- local status_ok_sl, scroller = pcall(require, "scroller.handlers.search")
  -- if status_ok_sl then
  --   pcall(scroller.setup)
  -- end
end

M.setup_scrollbar = function()
  local status_ok, scrollbar = pcall(require, "scrollbar")
  if not status_ok then
    return
  end

  scrollbar.setup({
    show = true,
    set_highlights = true,
    handle = {
      text = " ",
      color = nil,
      cterm = nil,
      highlight = "CursorColumn",
      hide_if_all_visible = true, -- Hides handle if all lines are visible
    },
    marks = {
      Search = {
        text = { "-", "=" },
        priority = 0,
        color = nil,
        cterm = nil,
        highlight = "DiagnosticVirtualTextInfo",
      },
      Error = {
        text = { "-", "=" },
        priority = 1,
        color = nil,
        cterm = nil,
        highlight = "DiagnosticVirtualTextError",
      },
      Warn = {
        text = { "-", "=" },
        priority = 2,
        color = nil,
        cterm = nil,
        highlight = "DiagnosticVirtualTextWarn",
      },
      Info = {
        text = { "-", "=" },
        priority = 3,
        color = nil,
        cterm = nil,
        highlight = "DiagnosticVirtualTextInfo",
      },
      Hint = {
        text = { "-", "=" },
        priority = 4,
        color = nil,
        cterm = nil,
        highlight = "DiagnosticVirtualTextHint",
      },
      Misc = {
        text = { "-", "=" },
        priority = 5,
        color = nil,
        cterm = nil,
        highlight = "Normal",
      },
    },
    excluded_buftypes = {
      "terminal",
    },
    excluded_filetypes = {
      "prompt",
      "TelescopePrompt",
      "neo-tree",
    },
    autocmd = {
      render = {
        "BufWinEnter",
        "TabEnter",
        "TermEnter",
        "WinEnter",
        "CmdwinLeave",
        "TextChanged",
        "VimResized",
        "WinScrolled",
      },
    },
    handlers = {
      diagnostic = true,
      search = false, -- Requires hlslens to be loaded, will run require("scrollbar.handlers.search").setup() for you
    },
  })
end

return M
