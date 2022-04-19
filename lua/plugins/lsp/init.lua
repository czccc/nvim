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
    Key("n", "K", vim.lsp.buf.hover, "Show Hover"):buffer(bufnr),
    Key("n", "g[", vim.diagnostic.goto_next, "Diagnostic Next"):buffer(bufnr),
    Key("n", "g]", vim.diagnostic.goto_prev, "Diagnostic Prev"):buffer(bufnr),
    Key("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic"):buffer(bufnr),
    Key("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic"):buffer(bufnr),
    Key("n", "ga", require("plugins.telescope").code_actions, "Code Actions"):buffer(bufnr),
    Key("n", "gd", require("plugins.telescope").lsp_definitions, "Goto Definition"):buffer(bufnr),
    Key("n", "gD", vim.lsp.buf.declaration, "Goto Declaration"):buffer(bufnr),
    Key("n", "gr", require("plugins.telescope").lsp_references, "Goto References"):buffer(bufnr),
    Key("n", "gI", require("plugins.telescope").lsp_implementations, "Goto Implementations"):buffer(bufnr),
    Key("n", "gs", vim.lsp.buf.signature_help, "Show Signature Help"):buffer(bufnr),
    Key("n", "gt", vim.lsp.buf.type_definition, "Goto Type Definition"):buffer(bufnr),
    Key("n", "gp", function()
      require("plugins.lsp.peek").Peek("definition")
    end, "Peek Definition"):buffer(bufnr),
    Key("n", "gl", require("plugins.lsp.utils").show_line_diagnostics, "Show Line Diagnostics"):buffer(bufnr),

    Key("n", "<Leader>l"):group("LSP"),
    Key("n", "<leader>la", require("plugins.telescope").code_actions, "Code Actions"):buffer(bufnr),
    Key("n", "<leader>ld", require("plugins.telescope").lsp_definitions, "Goto Definition"):buffer(bufnr),
    Key("n", "<leader>lD", vim.lsp.buf.declaration, "Goto Declaration"):buffer(bufnr),
    Key("n", "<leader>lf", vim.lsp.buf.formatting, "Format Code"):buffer(bufnr),
    Key("n", "<leader>lr", require("plugins.telescope").lsp_references, "Goto References"):buffer(bufnr),
    Key("n", "<leader>lR", vim.lsp.buf.rename, "Rename Symbol"):buffer(bufnr),
    Key("n", "<leader>lh", vim.lsp.buf.signature_help, "Show Signature Help"):buffer(bufnr),
    Key("n", "<leader>li", require("plugins.telescope").lsp_implementations, "Goto Implementations"):buffer(bufnr),
    Key("n", "<leader>lj", vim.diagnostic.goto_next, "Diagnostic Next"):buffer(bufnr),
    Key("n", "<leader>lk", vim.diagnostic.goto_prev, "Diagnostic Prev"):buffer(bufnr),
    Key("n", "<leader>ll", vim.lsp.codelens.run, "Code Lens"):buffer(bufnr),
    Key("n", "<leader>lq", vim.diagnostic.setloclist, "Quickfix"):buffer(bufnr),
    Key("n", "<leader>lr", require("plugins.telescope").lsp_references, "Goto References"):buffer(bufnr),
    Key("n", "<leader>lR", vim.lsp.buf.rename, "Rename Symbol"):buffer(bufnr),
    Key("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols"):buffer(bufnr),
    Key("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols"):buffer(bufnr),
    Key("n", "<leader>lw", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostic"):buffer(bufnr),
    Key("n", "<leader>lW", "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostic"):buffer(bufnr),

    Key("n", "<Leader>lp"):group("Peek"),
    Key("n", "<leader>lpd", wrap(require("plugins.lsp.peek").Peek, "definition"), "Definition"):buffer(bufnr),
    Key("n", "<leader>lpr", wrap(require("plugins.lsp.peek").Peek, "references"), "References"):buffer(bufnr),
    Key("n", "<leader>lpi", wrap(require("plugins.lsp.peek").Peek, "implementation"), "Implementation"):buffer(bufnr),
    Key("n", "<leader>lps", wrap(require("plugins.lsp.peek").Peek, "signature_help"), "Signature Help"):buffer(bufnr),
    Key("n", "<leader>lpt", wrap(require("plugins.lsp.peek").Peek, "type_definition"), "Type Definition"):buffer(bufnr),

    Key("n", "<Leader>lu"):group("Utils"),
    Key("n", "<Leader>lui", "<cmd>LspInfo<cr>", "Lsp Info"):buffer(bufnr),
    Key("n", "<Leader>luI", "<cmd>LspInstallInfo<cr>", "Lsp Installer"):buffer(bufnr),
    Key("n", "<Leader>lur", "<cmd>LspRestart<cr>", "Lsp Restart"):buffer(bufnr),

    Key("n", "<Leader>lt"):group("Trouble"),
    Key("n", "<Leader>ltd", "<cmd>Trouble document_diagnostics<cr>", "Diagnosticss"):buffer(bufnr),
    Key("n", "<Leader>ltf", "<cmd>Trouble lsp_definitions<cr>", "Definitions"):buffer(bufnr),
    Key("n", "<Leader>ltl", "<cmd>Trouble loclist<cr>", "LocationList"):buffer(bufnr),
    Key("n", "<Leader>ltq", "<cmd>Trouble quickfix<cr>", "QuickFix"):buffer(bufnr),
    Key("n", "<Leader>ltr", "<cmd>Trouble lsp_references<cr>", "References"):buffer(bufnr),
    Key("n", "<Leader>ltt", "<cmd>TodoTrouble<cr>", "Todo"):buffer(bufnr),
    Key("n", "<Leader>ltw", "<cmd>Trouble workspace_diagnostics<cr>", "Diagnosticss"):buffer(bufnr),
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
