local M = {}

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

  local lsp_installer_servers = require("nvim-lsp-installer.servers")
  local _, requested_server = lsp_installer_servers.get_server("rust_analyzer")

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
      cmd_env = requested_server._default_options.cmd_env,
      on_attach = function(client, bufnr)
        require("plugins.lsp").common_on_attach(client, bufnr)
        local Key = require("utils.key").Key
        require("utils.key").load({
          Key("n", "<Leader>mt", "<cmd>RustToggleInlayHints<cr>"):buffer(bufnr):desc("Toggle Inlay Hints"),
          Key("n", "<Leader>mr", "<cmd>RustRunnables<cr>"):buffer(bufnr):desc("Runnables"),
          Key("n", "<Leader>md", "<cmd>RustDebuggables<cr>"):buffer(bufnr):desc("Debuggables"),
          Key("n", "<Leader>me", "<cmd>RustExpandMacro<cr>"):buffer(bufnr):desc("Expand Macro"),
          Key("n", "<Leader>mc", "<cmd>RustOpenCargo<cr>"):buffer(bufnr):desc("Open Cargo"),
          Key("n", "<Leader>mR", "<cmd>RustReloadWorkspace<cr>"):buffer(bufnr):desc("Reload"),
          Key("n", "<Leader>ma", "<cmd>RustHoverActions<cr>"):buffer(bufnr):desc("Hover Actions"),
          Key("n", "<Leader>mA", "<cmd>RustHoverRange<cr>"):buffer(bufnr):desc("Hover Range"),
          Key("n", "<Leader>ml", "<cmd>RustJoinLines<cr>"):buffer(bufnr):desc("Join Lines"),
          Key("n", "<Leader>mj", "<cmd>RustMoveItemDown<cr>"):buffer(bufnr):desc("Move Item Down"),
          Key("n", "<Leader>mk", "<cmd>RustMoveItemUp<cr>"):buffer(bufnr):desc("Move Item Up"),
          Key("n", "<Leader>mp", "<cmd>RustParentModule<cr>"):buffer(bufnr):desc("Parent Module"),
          Key("n", "<Leader>ms", "<cmd>RustSSR<cr>"):buffer(bufnr):desc("Structural Search Replace"),
          Key("n", "<Leader>mg", "<cmd>RustViewCrateGraph<cr>"):buffer(bufnr):desc("View Crate Graph"),
          Key("n", "<Leader>mS", "<cmd>RustStartStandaloneServerForBuffer<cr>"):buffer(bufnr):desc("Standalone Server"),
        })
      end,
      on_init = require("plugins.lsp").common_on_init,
    },
    dap = {
      adapter = M.get_lldb_command(),
    },
  }
  rust_tools.setup(opts)
end

return M
