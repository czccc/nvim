local M = {}

M.packer = {
  "simrat39/rust-tools.nvim",
  -- "fabiocaruso/rust-tools.nvim",
  config = function()
    require("plugins.lsp.lang.rust").setup()
  end,
  ft = { "rust", "rs" },
  opt = true,
}

local executor = {}
executor.latest_buf_id = nil
executor.execute_command = function(command, args, cwd)
  local utils = require("rust-tools.utils.utils")
  -- local full_command = utils.chain_commands {
  --   utils.make_command_from_args("cd", { cwd }),
  --   utils.make_command_from_args(command, args),
  -- }
  local full_command = utils.make_command_from_args(command, args)
  utils.delete_buf(executor.latest_buf_id)
  executor.latest_buf_id = vim.api.nvim_create_buf(false, true)

  utils.split(false, executor.latest_buf_id)
  utils.resize(false, "-15")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, true, true), "", true)
  vim.api.nvim_buf_set_keymap(executor.latest_buf_id, "n", "<Esc>", ":q<CR>", { noremap = true })
  vim.api.nvim_buf_set_keymap(executor.latest_buf_id, "n", "<CR>", "i", { noremap = true })
  vim.api.nvim_buf_set_keymap(executor.latest_buf_id, "n", "<Tab>", "<C-w>k", { noremap = true })

  -- run the command
  vim.fn.termopen(full_command, { cwd = cwd })

  local function onDetach(_, _)
    executor.latest_buf_id = nil
  end

  vim.api.nvim_buf_attach(executor.latest_buf_id, false, { on_detach = onDetach })
end
-- executor.execute_command = require("plugins.async").exector_with_args

M.get_lldb_command = function()
  local path = require("utils.path")
  local extension_path = path.join(vim.env.HOME, ".vscode-server", "extensions", "vadimcn.vscode-lldb-1.6.10")
  local codelldb_path = path.join(extension_path, "adapter", "codelldb")
  local liblldb_path = path.join(extension_path, "lldb", "lib", "liblldb.so")
  -- print(path.is_file(codelldb_path), " ", codelldb_path)
  -- print(path.is_file(liblldb_path), " ", liblldb_path)
  local adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
  return adapter
end

M.setup = function()
  local status_ok, rust_tools = pcall(require, "rust-tools")
  if not status_ok then
    return
  end

  local opts = {
    tools = {
      autoSetHints = true,
      hover_with_actions = true,
      executor = executor, -- can be quickfix or termopen
      runnables = {
        use_telescope = true,
        prompt_prefix = "  ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "descending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.3,
          height = 0.50,
          preview_cutoff = 0,
          prompt_position = "bottom",
        },
      },
      debuggables = {
        use_telescope = true,
      },
      inlay_hints = {
        only_current_line = false,
        show_parameter_hints = true,
        parameter_hints_prefix = "<-",
        other_hints_prefix = "=>",
        max_len_align = false,
        max_len_align_padding = 1,
        right_align = false,
        right_align_padding = 7,
        highlight = "Comment",
      },
      hover_actions = {
        border = {
          { "╭", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╮", "FloatBorder" },
          { "│", "FloatBorder" },
          { "╯", "FloatBorder" },
          { "─", "FloatBorder" },
          { "╰", "FloatBorder" },
          { "│", "FloatBorder" },
        },
        auto_focus = true,
      },
    },
    server = {
      standalone = true,
      on_attach = function(client, bufnr)
        require("plugins.lsp").common_on_attach(client, bufnr)
        local mapping = {
          { "<Leader>mt", "<cmd>RustToggleInlayHints<cr>", "Toggle Inlay Hints" },
          { "<Leader>mr", "<cmd>RustRunnables<cr>", "Runnables" },
          { "<Leader>md", "<cmd>RustDebuggables<cr>", "Debuggables" },
          { "<Leader>me", "<cmd>RustExpandMacro<cr>", "Expand Macro" },
          { "<Leader>mc", "<cmd>RustOpenCargo<cr>", "Open Cargo" },
          { "<Leader>mR", "<cmd>RustReloadWorkspace<cr>", "Reload" },
          { "<Leader>ma", "<cmd>RustHoverActions<cr>", "Hover Actions" },
          { "<Leader>mA", "<cmd>RustHoverRange<cr>", "Hover Range" },
          { "<Leader>ml", "<cmd>RustJoinLines<cr>", "Join Lines" },
          { "<Leader>mj", "<cmd>RustMoveItemDown<cr>", "Move Item Down" },
          { "<Leader>mk", "<cmd>RustMoveItemUp<cr>", "Move Item Up" },
          { "<Leader>mp", "<cmd>RustParentModule<cr>", "Parent Module" },
          { "<Leader>ms", "<cmd>RustSSR<cr>", "Structural Search Replace" },
          { "<Leader>mg", "<cmd>RustViewCrateGraph<cr>", "View Crate Graph" },
          { "<Leader>mS", "<cmd>RustStartStandaloneServerForBuffer<cr>", "Standalone Server" },
        }
        for _, m in ipairs(mapping) do
          utils.Key("n", m[1], m[2], m[3]):buffer(bufnr):set()
        end
      end,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    },
    dap = {
      adapter = M.get_lldb_command(),
    },
  }
  rust_tools.setup(opts)
end

return M
