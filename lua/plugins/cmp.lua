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
  -- {
  --   "hrsh7th/cmp-cmdline",
  -- },
  {
    "f3fora/cmp-spell",
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

local has_words_before = function()
  local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

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
    mapping = cmp.mapping.preset.insert({
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<Tab>"] = cmp.mapping(function(fallback)
        local copilot_keys = vim.fn["copilot#Accept"]()
        if cmp.visible() then
          cmp.select_next_item()
        elseif copilot_keys ~= "" then -- prioritise copilot over snippets
          -- Copilot keys do not need to be wrapped in termcodes
          vim.api.nvim_feedkeys(copilot_keys, "i", true)
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      ["<Esc>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort()
        elseif luasnip.expand_or_jumpable() then
          luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] = nil
          fallback()
        else
          fallback()
        end
      end),
      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() and cmp.confirm(M.config.confirm_opts) then
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          end
          return
        end
        if luasnip.expand_or_jumpable() then
          if not luasnip.jump(1) then
            fallback()
          end
        else
          fallback()
        end
      end),
    }),
  }
  cmp.setup(M.config)
  -- cmp.setup.cmdline(":", {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = {
  --     { name = "path" },
  --     { name = "cmdline" },
  --     { name = "nvim_lua" },
  --   },
  -- })
  -- cmp.setup.cmdline("/", {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = {
  --     { name = "buffer" },
  --   },
  -- })
  -- cmp.setup.cmdline("?", {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = {
  --     { name = "buffer" },
  --   },
  -- })
  cmp.setup.filetype("markdown", {
    sources = cmp.config.sources({
      { name = "copilot", group_index = 2 },
      { name = "nvim_lsp" },
      { name = "buffer", max_item_count = 5 },
      { name = "spell" },
    }),
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
