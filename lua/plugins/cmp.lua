local M = {}

M.packers = {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    opt = true,
    config = function()
      require("plugins.cmp").setup_cmp()
    end,
    wants = { "LuaSnip" },
    requires = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "f3fora/cmp-spell",
      "hrsh7th/cmp-cmdline",
      "dmitmel/cmp-cmdline-history",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      {
        "L3MON4D3/LuaSnip",
        wants = "friendly-snippets",
        config = function()
          require("plugins.cmp").setup_luasnip()
        end,
      },
      {
        "danymat/neogen",
        config = function()
          require("neogen").setup({ snippet_engine = "luasnip" })
        end,
        requires = "nvim-treesitter/nvim-treesitter",
      },
      -- {
      --   "abecodes/tabout.nvim",
      --   config = function()
      --     require("plugins.cmp").setup_tabout()
      --   end,
      -- },
    },
  },
}

M.config = {}

M.init = function() end

M.setup_luasnip = function()
  require("luasnip/loaders/from_vscode").lazy_load()
  require("luasnip/loaders/from_vscode").lazy_load({ paths = { "./snippets" } })
  local types = require("luasnip.util.types")
  local util = require("luasnip.util.util")
  local luasnip = require("luasnip")
  luasnip.config.setup({
    history = false,
    update_events = "InsertLeave",
    enable_autosnippets = true,
    region_check_events = "CursorHold,InsertLeave",
    delete_check_events = "TextChanged,InsertEnter",
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { "●", "GruvboxOrange" } },
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { "●", "GruvboxBlue" } },
        },
      },
    },
    parser_nested_assembler = function(_, snippet)
      local select = function(snip, no_move)
        snip.parent:enter_node(snip.indx)
        -- upon deletion, extmarks of inner nodes should shift to end of
        -- placeholder-text.
        for _, node in ipairs(snip.nodes) do
          node:set_mark_rgrav(true, true)
        end

        -- SELECT all text inside the snippet.
        if not no_move then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
          local pos_begin, pos_end = snip.mark:pos_begin_end()
          util.normal_move_on(pos_begin)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("v", true, false, true), "n", true)
          util.normal_move_before(pos_end)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("o<C-G>", true, false, true), "n", true)
        end
      end
      function snippet:jump_into(dir, no_move)
        if self.active then
          -- inside snippet, but not selected.
          if dir == 1 then
            self:input_leave()
            return self.next:jump_into(dir, no_move)
          else
            select(self, no_move)
            return self
          end
        else
          -- jumping in from outside snippet.
          self:input_enter()
          if dir == 1 then
            select(self, no_move)
            return self
          else
            return self.inner_last:jump_into(dir, no_move)
          end
        end
      end

      -- this is called only if the snippet is currently selected.
      function snippet:jump_from(dir, no_move)
        if dir == 1 then
          return self.inner_first:jump_into(dir, no_move)
        else
          self:input_leave()
          return self.prev:jump_into(dir, no_move)
        end
      end

      return snippet
    end,
  })
end

M.setup_cmp = function()
  local status_cmp_ok, cmp = pcall(require, "cmp")
  if not status_cmp_ok then
    vim.cmd([[ packadd cmp ]])
    return
  end
  local types = require("cmp.types")
  local status_luasnip_ok, luasnip = pcall(require, "luasnip")
  if not status_luasnip_ok then
    vim.cmd([[ packadd luasnip ]])
    return
  end

  local feedkey = function(key, mode, replace)
    if replace then
      key = vim.api.nvim_replace_termcodes(key, true, false, true)
      vim.api.nvim_feedkeys(key, mode, false)
    else
      vim.api.nvim_feedkeys(key, mode, true)
    end
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
    view = {
      entries = { name = "custom", selection_order = "near_cursor" },
    },
    experimental = {
      ghost_text = false,
      native_menu = false,
      custom_menu = true,
    },
    formatting = {
      format = require("utils.lspkind").cmp_format({ maxwidth = 50 }),
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    sources = {
      { name = "nvim_lsp" },
      { name = "path", max_item_count = 5, keyword_length = 3 },
      { name = "luasnip", max_item_count = 5 },
      { name = "nvim_lua" },
      { name = "buffer", max_item_count = 5, keyword_length = 3 },
    },
    mapping = cmp.mapping.preset.insert({
      ["<Down>"] = {
        i = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
      },
      ["<Up>"] = {
        i = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
      },
      ["<C-n>"] = {
        i = function()
          if cmp.visible() then
            cmp.select_next_item({ behavior = types.cmp.SelectBehavior.Insert })
          else
            cmp.complete()
          end
        end,
        c = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
          else
            fallback()
          end
        end,
      },
      ["<C-p>"] = {
        i = function()
          if cmp.visible() then
            cmp.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert })
          else
            cmp.complete()
          end
        end,
        c = function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = types.cmp.SelectBehavior.Insert })
          else
            fallback()
          end
        end,
      },
      ["<C-y>"] = {
        i = cmp.mapping.complete({}),
        c = cmp.mapping.complete({}),
      },
      ["<C-e>"] = {
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      },
      ["<C-d>"] = {
        i = cmp.mapping.scroll_docs(-4),
      },
      ["<C-f>"] = {
        i = cmp.mapping.scroll_docs(4),
      },
      ["<Tab>"] = {
        i = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.jumpable() then
            -- luasnip.jump()
            luasnip.expand_or_jump()
            -- elseif luasnip.expand_or_locally_jumpable() then
            --   luasnip.expand_or_jump()
            -- elseif has_words_before() then
            --   cmp.complete()
          else
            local next_char = vim.api.nvim_eval("strcharpart(getline('.')[col('.') - 1:], 0, 1)")
            if
              next_char == '"'
              or next_char == "'"
              or next_char == "`"
              or next_char == ")"
              or next_char == "]"
              or next_char == "}"
            then
              feedkey("<Right>", "n", true)
            else
              fallback()
            end
          end
        end,
        s = function(fallback)
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end,
        c = function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            feedkey("<C-z>", "n")
          end
        end,
      },
      ["<S-Tab>"] = {
        i = function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end,
        s = function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end,
        c = function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            feedkey("<C-z>", "n")
          end
        end,
      },
      ["<Esc>"] = {
        i = function(fallback)
          if cmp.visible() then
            cmp.abort()
          elseif luasnip.expand_or_locally_jumpable() then
            luasnip.session.current_nodes[vim.api.nvim_get_current_buf()] = nil
            fallback()
          else
            fallback()
          end
        end,
        -- c = function(fallback)
        --   if cmp.visible() then
        --     cmp.close()
        --   else
        --     -- feedkey("<C-c>", "i")
        --     fallback()
        --   end
        -- end,
      },
      ["<CR>"] = { i = cmp.mapping.confirm({ select = false }) },
    }),
  }
  cmp.setup(M.config)
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "path" },
      { name = "cmdline" },
      { name = "cmdline_history", max_item_count = 5, keyword_length = 3 },
      { name = "nvim_lua" },
    },
    formatting = {
      format = require("utils.lspkind").cmp_format({}),
    },
  })
  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
      { name = "cmdline_history", max_item_count = 5, keyword_length = 3 },
    },
    formatting = {
      format = require("utils.lspkind").cmp_format({}),
    },
  })
  cmp.setup.cmdline("?", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
      { name = "cmdline_history", max_item_count = 5, keyword_length = 3 },
    },
    formatting = {
      format = require("utils.lspkind").cmp_format({}),
    },
  })
  cmp.setup.filetype("markdown", {
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "buffer", max_item_count = 5 },
      { name = "spell" },
    }),
  })
end

M.setup_tabout = function()
  require("tabout").setup({
    tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
    backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
    act_as_tab = true, -- shift content if tab out is not possible
    act_as_shift_tab = true, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
    enable_backwards = true, -- well ...
    completion = true, -- if the tabkey is used in a completion pum
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
