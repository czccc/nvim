local M = {}

M.packer = {
  "nvim-pack/nvim-spectre",
  config = function()
    require("plugins.spectre").setup()
  end,
}

M.setup = function()
  require("spectre").setup {
    color_devicons = true,
    open_cmd = "vnew",
    live_update = true, -- auto excute search again when you write any file in vim
    line_sep_start = "┌-----------------------------------------",
    result_padding = "¦  ",
    line_sep = "└-----------------------------------------",
    highlight = {
      ui = "String",
      search = "IncSearch",
      replace = "WildMenu",
    },
    mapping = {
      ["toggle_line"] = {
        map = "<leader>Sd",
        cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
        desc = "toggle current item",
      },
      ["enter_file"] = {
        map = "<cr>",
        cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
        desc = "goto current file",
      },
      ["send_to_qf"] = {
        map = "<leader>Sq",
        cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
        desc = "send all item to quickfix",
      },
      ["replace_cmd"] = {
        map = "<leader>Sc",
        cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
        desc = "input replace vim command",
      },
      ["show_option_menu"] = {
        map = "<leader>So",
        cmd = "<cmd>lua require('spectre').show_options()<CR>",
        desc = "show option",
      },
      ["run_replace"] = {
        map = "<leader>SR",
        cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
        desc = "replace all",
      },
      ["change_view_mode"] = {
        map = "<leader>Stv",
        cmd = "<cmd>lua require('spectre').change_view()<CR>",
        desc = "change result view mode",
      },
      ["toggle_live_update"] = {
        map = "<leader>Stu",
        cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
        desc = "update change when vim write file.",
      },
      ["toggle_ignore_case"] = {
        map = "<leader>Sti",
        cmd = "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
        desc = "toggle ignore case",
      },
      ["toggle_ignore_hidden"] = {
        map = "<leader>Sth",
        cmd = "<cmd>lua require('spectre').change_options('hidden')<CR>",
        desc = "toggle search hidden",
      },
      -- you can put your mapping here it only use normal mode
    },
    find_engine = {
      -- rg is map with finder_cmd
      ["rg"] = {
        cmd = "rg",
        -- default args
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        options = {
          ["ignore-case"] = {
            value = "--ignore-case",
            icon = "[I]",
            desc = "ignore case",
          },
          ["hidden"] = {
            value = "--hidden",
            desc = "hidden file",
            icon = "[H]",
          },
          -- you can put any rg search option you want here it can toggle with
          -- show_option function
        },
      },
      ["ag"] = {
        cmd = "ag",
        args = {
          "--vimgrep",
          "-s",
        },
        options = {
          ["ignore-case"] = {
            value = "-i",
            icon = "[I]",
            desc = "ignore case",
          },
          ["hidden"] = {
            value = "--hidden",
            desc = "hidden file",
            icon = "[H]",
          },
        },
      },
    },
    replace_engine = {
      ["sed"] = {
        cmd = "sed",
        args = nil,
      },
      options = {
        ["ignore-case"] = {
          value = "--ignore-case",
          icon = "[I]",
          desc = "ignore case",
        },
      },
    },
    default = {
      find = {
        --pick one of item in find_engine
        cmd = "rg",
        options = { "ignore-case" },
      },
      replace = {
        --pick one of item in replace_engine
        cmd = "sed",
      },
    },
    replace_vim_cmd = "cdo",
    is_open_target_win = true, --open file on opener window
    is_insert_mode = false, -- start open panel on is_insert_mode
  }
  local wk = require "plugins.which_key"
  wk.register {
    ["S"] = {
      name = "Spectre",
      ["w"] = { "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", "Spectre Word" },
      ["v"] = { "<cmd>lua require('spectre').open_visual()<CR>", "Spectre Visual" },
      ["s"] = { "<cmd>lua require('spectre').open()<CR>", "Spectre Open" },
      ["p"] = { "<cmd>lua require('spectre').open_file_search()<CR>", "Spectre File Search" },
    },
  }
  wk.register({
    ["S"] = {
      ["v"] = { "<cmd>lua require('plugins.spectre').visual_selection()<CR>", "Spectre Visual" },
    },
  }, wk.config.vopts)
end

M.visual_selection = function()
  local save_previous = vim.fn.getreg "a"
  vim.api.nvim_command 'silent! normal! "ay'
  local selection = vim.fn.trim(vim.fn.getreg "a")
  vim.fn.setreg("a", save_previous)
  selection = vim.fn.substitute(selection, [[\n]], [[\\n]], "g")
  require("spectre").open { search_text = selection }
end

return M
