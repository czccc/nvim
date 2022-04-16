local M = {}
local Log = require("core.log")
local autocmds = require("core.autocmds")

M.packers = {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("plugins.lsp").setup()
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require("plugins.lsp.null-ls").setup()
    end,
  },
  {
    "williamboman/nvim-lsp-installer",
    config = function()
      require("nvim-lsp-installer").on_server_ready(function(server)
        require("plugins.lsp.manager").setup(server.name)
      end)
    end,
  },
  -- {
  --   "filipdutescu/renamer.nvim",
  --   config = function()
  --     require("plugins.lsp.renamer").config()
  --   end,
  -- },
  {
    "folke/lua-dev.nvim",
    module = "lua-dev",
  },
}

M.config = require("plugins.lsp.config")

local function add_lsp_buffer_keybindings(bufnr)
  local Key = require("utils.key").Key
  require("utils.key").load({
    Key("n", "K", vim.lsp.buf.hover):buffer(bufnr):desc("Show Hover"),
    Key("n", "g[", vim.diagnostic.goto_next):buffer(bufnr):desc("Diagnostic Next"),
    Key("n", "g]", vim.diagnostic.goto_prev):buffer(bufnr):desc("Diagnostic Prev"),
    Key("n", "]d", vim.diagnostic.goto_next):buffer(bufnr):desc("Next Diagnostic"),
    Key("n", "[d", vim.diagnostic.goto_prev):buffer(bufnr):desc("Previous Diagnostic"),
    Key("n", "ga", require("plugins.telescope").code_actions):buffer(bufnr):desc("Code Actions"),
    Key("n", "gd", require("plugins.telescope").lsp_definitions):buffer(bufnr):desc("Goto Definition"),
    Key("n", "gD", vim.lsp.buf.declaration):buffer(bufnr):desc("Goto Declaration"),
    Key("n", "gr", require("plugins.telescope").lsp_references):buffer(bufnr):desc("Goto References"),
    Key("n", "gI", require("plugins.telescope").lsp_implementations):buffer(bufnr):desc("Goto Implementations"),
    Key("n", "gs", vim.lsp.buf.signature_help):buffer(bufnr):desc("Show Signature Help"),
    Key("n", "gt", vim.lsp.buf.type_definition):buffer(bufnr):desc("Goto Type Definition"),
    Key("n", "gp", function()
      require("plugins.lsp.peek").Peek("definition")
    end):buffer(bufnr):desc("Peek Definition"),
    Key("n", "gl", require("plugins.lsp.utils").show_line_diagnostics):buffer(bufnr):desc("Show Line Diagnostics"),

    Key("n", "<Leader>l"):group("LSP"),
    Key("n", "<leader>la", require("plugins.telescope").code_actions):buffer(bufnr):desc("Code Actions"),
    Key("n", "<leader>ld", require("plugins.telescope").lsp_definitions):buffer(bufnr):desc("Goto Definition"),
    Key("n", "<leader>lD", vim.lsp.buf.declaration):buffer(bufnr):desc("Goto Declaration"),
    Key("n", "<leader>lf", vim.lsp.buf.formatting):buffer(bufnr):desc("Format Code"),
    Key("n", "<leader>lr", require("plugins.telescope").lsp_references):buffer(bufnr):desc("Goto References"),
    Key("n", "<leader>lR", vim.lsp.buf.rename):buffer(bufnr):desc("Rename Symbol"),
    Key("n", "<leader>lh", vim.lsp.buf.signature_help):buffer(bufnr):desc("Show Signature Help"),
    Key("n", "<leader>li", require("plugins.telescope").lsp_implementations):buffer(bufnr):desc("Goto Implementations"),
    Key("n", "<leader>lj", vim.diagnostic.goto_next):buffer(bufnr):desc("Diagnostic Next"),
    Key("n", "<leader>lk", vim.diagnostic.goto_prev):buffer(bufnr):desc("Diagnostic Prev"),
    Key("n", "<leader>ll", vim.lsp.codelens.run):buffer(bufnr):desc("Code Lens"),
    Key("n", "<leader>lq", vim.diagnostic.setloclist):buffer(bufnr):desc("Quickfix"),
    Key("n", "<leader>lr", require("plugins.telescope").lsp_references):buffer(bufnr):desc("Goto References"),
    Key("n", "<leader>lR", vim.lsp.buf.rename):buffer(bufnr):desc("Rename Symbol"),
    Key("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>"):buffer(bufnr):desc("Document Symbols"),
    Key("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>"):buffer(bufnr):desc("Workspace Symbols"),
    Key("n", "<leader>lw", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>")
      :buffer(bufnr)
      :desc("Buffer Diagnostic"),
    Key("n", "<leader>lW", "<cmd>Telescope diagnostics<cr>"):buffer(bufnr):desc("Workspace Diagnostic"),

    Key("n", "<Leader>lp"):group("Peek"),
    Key("n", "<leader>lpd", function()
      require("plugins.lsp.peek").Peek("definition")
    end):buffer(bufnr):desc("Peek Definition"),
    Key("n", "<leader>lpt", function()
      require("plugins.lsp.peek").Peek("typeDefinition")
    end):buffer(bufnr):desc("Peek Type Definition"),
    Key("n", "<leader>lpi", function()
      require("plugins.lsp.peek").Peek("implementation")
    end):buffer(bufnr):desc("Peek Implementations"),

    Key("n", "<Leader>lu"):group("Utils"),
    Key("n", "<Leader>lui", "<cmd>LspInfo<cr>"):buffer(bufnr):desc("Lsp Info"),
    Key("n", "<Leader>luI", "<cmd>LspInstallInfo<cr>"):buffer(bufnr):desc("Lsp Installer"),
    Key("n", "<Leader>lur", "<cmd>LspRestart<cr>"):buffer(bufnr):desc("Lsp Restart"),

    Key("n", "<Leader>lt"):group("Trouble"),
    Key("n", "<Leader>ltd", "<cmd>Trouble document_diagnostics<cr>"):buffer(bufnr):desc("Diagnosticss"),
    Key("n", "<Leader>ltf", "<cmd>Trouble lsp_definitions<cr>"):buffer(bufnr):desc("Definitions"),
    Key("n", "<Leader>ltl", "<cmd>Trouble loclist<cr>"):buffer(bufnr):desc("LocationList"),
    Key("n", "<Leader>ltq", "<cmd>Trouble quickfix<cr>"):buffer(bufnr):desc("QuickFix"),
    Key("n", "<Leader>ltr", "<cmd>Trouble lsp_references<cr>"):buffer(bufnr):desc("References"),
    Key("n", "<Leader>ltt", "<cmd>TodoTrouble<cr>"):buffer(bufnr):desc("Todo"),
    Key("n", "<Leader>ltw", "<cmd>Trouble workspace_diagnostics<cr>"):buffer(bufnr):desc("Diagnosticss"),
  })
end

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
  end

  return capabilities
end

local function select_default_formater(client)
  if client.name == "null-ls" or not client.resolved_capabilities.document_formatting then
    return
  end
  Log:debug("Checking for formatter overriding for " .. client.name)
  local formatters = require("plugins.lsp.null-ls.formatters")
  local client_filetypes = client.config.filetypes or {}
  for _, filetype in ipairs(client_filetypes) do
    if #vim.tbl_keys(formatters.list_registered(filetype)) > 0 then
      Log:debug("Formatter overriding detected. Disabling formatting capabilities for " .. client.name)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end
end

function M.common_on_exit(_, _)
  autocmds.disable_lsp_document_highlight()
  autocmds.disable_code_lens_refresh()
end

function M.common_on_init(client, _)
  select_default_formater(client)
end

function M.common_on_attach(client, bufnr)
  autocmds.enable_lsp_document_highlight(client.id)
  if client.resolved_capabilities.code_lens then
    autocmds.enable_code_lens_refresh()
  end
  add_lsp_buffer_keybindings(bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

function M.get_common_opts()
  return {
    on_attach = M.common_on_attach,
    on_init = M.common_on_init,
    on_exit = M.common_on_exit,
    capabilities = M.common_capabilities(),
  }
end

function M.setup()
  Log:debug("Setting up LSP support")

  local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
  if not lsp_status_ok then
    return
  end
  lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
    capabilities = M.common_capabilities(),
  })

  for _, sign in ipairs(M.config.diagnostics.signs.values) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  vim.diagnostic.config(M.config.diagnostics)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, M.config.float)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, M.config.float)

  require("core.autocmds").configure_format_on_save()
end

return M
