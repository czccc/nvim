local M = {}

M.packers = {
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require("plugins.cmp").setup_cmp()
    end,
    requires = {
      "L3MON4D3/LuaSnip",
    },
  },
  {
    "rafamadriz/friendly-snippets",
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip/loaders/from_vscode").lazy_load()
      require("luasnip/loaders/from_vscode").lazy_load({ paths = { "./snippets" } })
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "saadparwaiz1/cmp_luasnip",
  },
  {
    "hrsh7th/cmp-buffer",
  },
  {
    "hrsh7th/cmp-path",
  },
  {
    "hrsh7th/cmp-cmdline",
  },
  {
    "danymat/neogen",
    config = function()
      require("neogen").setup({ snippet_engine = "luasnip" })
    end,
    requires = "nvim-treesitter/nvim-treesitter",
  },
  {
    "abecodes/tabout.nvim",
    config = function()
      require("plugins.cmp").setup_tabout()
    end,
  },
  {
    "github/copilot.vim",
    -- "gelfand/copilot.vim",
    config = function()
      require("plugins.cmp").setup_copilot()
    end,
    -- disable = true,
  },
  -- {
  --   "hrsh7th/cmp-copilot",
  --   -- disable = true,
  -- },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "InsertEnter",
  --   config = function()
  --     vim.schedule(function()
  --       require "copilot"
  --     end)
  --   end,
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua", "nvim-cmp" },
  -- },
}

M.config = {}

M.methods = {}

---checks if the character preceding the cursor is a space character
---@return boolean true if it is a space character, false otherwise
local check_backspace = function()
  local col = vim.fn.col(".") - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end
M.methods.check_backspace = check_backspace

local function T(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

---wraps vim.fn.feedkeys while replacing key codes with escape codes
---Ex: feedkeys("<CR>", "n") becomes feedkeys("^M", "n")
---@param key string
---@param mode string
local function feedkeys(key, mode)
  vim.fn.feedkeys(T(key), mode)
end
M.methods.feedkeys = feedkeys

---checks if emmet_ls is available and active in the buffer
---@return boolean true if available, false otherwise
local is_emmet_active = function()
  local clients = vim.lsp.buf_get_clients()

  for _, client in pairs(clients) do
    if client.name == "emmet_ls" then
      return true
    end
  end
  return false
end
M.methods.is_emmet_active = is_emmet_active

---when inside a snippet, seeks to the nearest luasnip field if possible, and checks if it is jumpable
---@param dir number 1 for forward, -1 for backward; defaults to 1
---@return boolean true if a jumpable luasnip field is found while inside a snippet
local function jumpable(dir)
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then
    return
  end

  local win_get_cursor = vim.api.nvim_win_get_cursor
  local get_current_buf = vim.api.nvim_get_current_buf

  local function inside_snippet()
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snip_begin_pos, snip_end_pos = node.parent.snippet.mark:pos_begin_end()
    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1 -- LuaSnip is 0-based not 1-based like nvim for rows
    return pos[1] >= snip_begin_pos[1] and pos[1] <= snip_end_pos[1]
  end

  ---sets the current buffer's luasnip to the one nearest the cursor
  ---@return boolean true if a node is found, false otherwise
  local function seek_luasnip_cursor_node()
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1
    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snippet = node.parent.snippet
    local exit_node = snippet.insert_nodes[0]

    -- exit early if we're past the exit node
    if exit_node then
      local exit_pos_end = exit_node.mark:pos_end()
      if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    node = snippet.inner_first:jump_into(1, true)
    while node ~= nil and node.next ~= nil and node ~= snippet do
      local n_next = node.next
      local next_pos = n_next and n_next.mark:pos_begin()
      local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
        or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

      -- Past unmarked exit node, exit early
      if n_next == nil or n_next == snippet.next then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end

      if candidate then
        luasnip.session.current_nodes[get_current_buf()] = node
        return true
      end

      local ok
      ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
      if not ok then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    -- No candidate, but have an exit node
    if exit_node then
      -- to jump to the exit node, seek to snippet
      luasnip.session.current_nodes[get_current_buf()] = snippet
      return true
    end

    -- No exit node, exit from snippet
    snippet:remove_from_jumplist()
    luasnip.session.current_nodes[get_current_buf()] = nil
    return false
  end

  if dir == -1 then
    return inside_snippet() and luasnip.jumpable(-1)
  else
    return inside_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable()
  end
end

M.methods.jumpable = jumpable

M.setup_cmp = function()
  local status_cmp_ok, cmp = pcall(require, "cmp")
  if not status_cmp_ok then
    vim.cmd([[ packadd cmp ]])
    return
  end
  local status_luasnip_ok, luasnip = pcall(require, "luasnip")
  if not status_luasnip_ok then
    vim.cmd([[ packadd luasnip ]])
    return
  end

  M.config = {
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    completion = {
      ---@usage The minimum length of a word to complete on.
      keyword_length = 1,
    },
    experimental = {
      ghost_text = true,
      native_menu = false,
      custom_menu = true,
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      kind_icons = {
        Class = " ",
        Color = " ",
        Constant = "ﲀ ",
        Constructor = " ",
        Enum = " ",
        EnumMember = " ",
        Event = " ",
        Field = " ",
        File = " ",
        Folder = " ",
        Function = " ",
        Interface = "ﰮ ",
        Keyword = " ",
        Method = " ",
        Module = " ",
        Operator = "",
        Property = " ",
        Reference = " ",
        Snippet = " ",
        Struct = " ",
        Text = " ",
        TypeParameter = " ",
        Unit = " ",
        Value = " ",
        Variable = " ",
      },
      source_names = {
        nvim_lsp = "(LSP)",
        emoji = "(Emoji)",
        path = "(Path)",
        calc = "(Calc)",
        cmp_tabnine = "(Tabnine)",
        vsnip = "(Snippet)",
        luasnip = "(Snippet)",
        buffer = "(Buffer)",
        copilot = "(Copilot)",
      },
      duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
      },
      duplicates_default = 0,
      format = function(entry, vim_item)
        vim_item.kind = M.config.formatting.kind_icons[vim_item.kind]
        vim_item.menu = M.config.formatting.source_names[entry.source.name]
        vim_item.dup = M.config.formatting.duplicates[entry.source.name] or M.config.formatting.duplicates_default
        return vim_item
      end,
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    window = {
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      scrollbar = "║",
      documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        scrollbar = "║",
      },
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "copilot", group_index = 2 },
      { name = "path", max_item_count = 5 },
      { name = "luasnip", max_item_count = 3 },
      { name = "cmp_tabnine" },
      { name = "nvim_lua" },
      { name = "buffer", max_item_count = 5 },
      { name = "calc" },
      { name = "emoji" },
      { name = "treesitter" },
      { name = "crates" },
    },
    mapping = {
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<Tab>"] = cmp.mapping(function(fallback)
        local copilot_keys = vim.fn["copilot#Accept"]()
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.api.nvim_get_mode().mode == "c" then
          fallback()
        elseif copilot_keys ~= "" then -- prioritise copilot over snippets
          -- Copilot keys do not need to be wrapped in termcodes
          vim.api.nvim_feedkeys(copilot_keys, "i", true)
        elseif luasnip.expandable() then
          luasnip.expand()
        elseif jumpable() then
          luasnip.jump(1)
        elseif check_backspace() then
          fallback()
        else
          -- feedkeys("<Plug>(Tabout)", "")
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.api.nvim_get_mode().mode == "c" then
          fallback()
        elseif jumpable(-1) then
          luasnip.jump(-1)
        else
          -- feedkeys("<Plug>(TaboutBack)", "")
          fallback()
        end
      end, {
        "i",
        "s",
      }),

      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<Esc>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort()
        elseif jumpable() then
          luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] = nil
          fallback()
        else
          fallback()
        end
      end),
      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() and cmp.confirm(M.config.confirm_opts) then
          if jumpable() then
            luasnip.jump(1)
          end
          return
        end
        if jumpable() then
          if not luasnip.jump(1) then
            fallback()
          end
        else
          fallback()
        end
      end),
    },
  }
  require("cmp").setup(M.config)
  require("cmp").setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "path" },
      { name = "cmdline" },
    },
  })
  require("cmp").setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })
end

M.setup_copilot = function()
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_assume_mapped = true
  vim.g.copilot_tab_fallback = ""
  vim.g.copilot_filetypes = {
    ["*"] = false,
    python = true,
    lua = true,
    go = true,
    rust = true,
    html = true,
    c = true,
    cpp = true,
    java = true,
    javascript = true,
    typescript = true,
    javascriptreact = true,
    typescriptreact = true,
    terraform = true,
  }
  require("core.keymap").load({
    ["i"] = {
      ["<c-h>"] = { [[copilot#Accept("\<CR>")]], { expr = true, script = true } },
      ["<c-l>"] = { [[copilot#Accept("\<CR>")]], { expr = true, script = true } },
      ["<M-]>"] = { "<Plug>(copilot-next)", { silent = true } },
      ["<M-[>"] = { "<Plug>(copilot-previous)", { silent = true } },
      ["<M-\\>"] = { "<Cmd>vertical Copilot panel<CR>", { silent = true } },
    },
  })
end

M.setup_tabout = function()
  require("tabout").setup({
    tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
    backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
    act_as_tab = true, -- shift content if tab out is not possible
    act_as_shift_tab = true, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
    enable_backwards = true, -- well ...
    completion = false, -- if the tabkey is used in a completion pum
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = "`", close = "`" },
      { open = "(", close = ")" },
      { open = "[", close = "]" },
      { open = "{", close = "}" },
    },
    ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
    exclude = {}, -- tabout will ignore these filetypes
  })
end

return M
