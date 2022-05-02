local M = {}
local AuCmd = utils.AuCmd
local Group = utils.Group

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
  {
    "folke/lua-dev.nvim",
    module = "lua-dev",
  },
}

M.config = require("plugins.lsp.config")

local function add_lsp_buffer_keybindings(bufnr)
  local Key = utils.Key
  utils.load({
    Key("n", "K", vim.lsp.buf.hover, "Show Hover"):buffer(bufnr),
    Key("n", "g[", vim.diagnostic.goto_next, "Diagnostic Next"):buffer(bufnr),
    Key("n", "g]", vim.diagnostic.goto_prev, "Diagnostic Prev"):buffer(bufnr),
    Key("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic"):buffer(bufnr),
    Key("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic"):buffer(bufnr),
    Key("n", "ga", vim.lsp.buf.code_action, "Code Actions"):buffer(bufnr),
    Key("n", "gd", require("plugins.telescope").lsp_definitions, "Goto Definition"):buffer(bufnr),
    Key("n", "gD", vim.lsp.buf.declaration, "Goto Declaration"):buffer(bufnr),
    Key("n", "gI", require("plugins.telescope").lsp_implementations, "Goto Implementations"):buffer(bufnr),
    -- Key("n", "gs", vim.lsp.buf.signature_help, "Show Signature Help"):buffer(bufnr),
    Key("n", "gt", vim.lsp.buf.type_definition, "Goto Type Definition"):buffer(bufnr),
    Key("n", "gl", wrap(vim.diagnostic.open_float, 0, { scope = "line" }), "Show Line Diagnostics"):buffer(bufnr),
    Key("n", "gL", vim.lsp.codelens.run, "Code Lens"):buffer(bufnr),
    Key("n", "gr", require("plugins.telescope").lsp_references, "Goto References"):buffer(bufnr),
    Key("n", "gR", vim.lsp.buf.rename, "Rename Symbol"):buffer(bufnr),
    Key("n", "gp", wrap(require("plugins.lsp.peek").Peek, "definition"), "Peek Definition"):buffer(bufnr),
    Key("n", "gF", vim.lsp.buf.formatting, "Format Code"):buffer(bufnr),

    Key("n", "<Leader>l"):group("LSP"),
    Key("n", "<leader>lh", vim.lsp.buf.signature_help, "Show Signature Help"):buffer(bufnr),
    Key("n", "<leader>lq", vim.diagnostic.setloclist, "Quickfix"):buffer(bufnr),
    Key("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols"):buffer(bufnr),
    Key("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols"):buffer(bufnr),
    Key("n", "<leader>ld", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostic"):buffer(bufnr),
    Key("n", "<leader>lD", "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostic"):buffer(bufnr),

    Key("n", "<Leader>li", "<cmd>LspInfo<cr>", "Lsp Info"):buffer(bufnr),
    Key("n", "<Leader>lI", "<cmd>LspInstallInfo<cr>", "Lsp Installer"):buffer(bufnr),
    Key("n", "<Leader>lr", "<cmd>LspRestart<cr>", "Lsp Restart"):buffer(bufnr),
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
  local formatters = require("plugins.lsp.null-ls.formatters")
  local client_filetypes = client.config.filetypes or {}
  for _, filetype in ipairs(client_filetypes) do
    if #vim.tbl_keys(formatters.list_registered(filetype)) > 0 then
      -- vim.notify("Formatter overriding detected. Disabling formatting capabilities for " .. client.name, "INFO")
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
    end
  end
end

function M.common_on_exit(_, _)
  Group("UserLSPDocumentHighlight"):unset()
  Group("UserLSPCodeLensRefresh"):unset()
end

function M.common_on_init(client, _)
  select_default_formater(client)
end

function M.common_on_attach(client, bufnr)
  local function conditional_document_highlight(id)
    local client_ok, method_supported = pcall(function()
      return vim.lsp.get_client_by_id(id).resolved_capabilities.document_highlight
    end)
    if not client_ok or not method_supported then
      return
    end
    vim.lsp.buf.document_highlight()
  end

  Group("UserLSPDocumentHighlight")
    :extend({
      AuCmd("CursorHold"):buffer(bufnr):callback(wrap(conditional_document_highlight, client.id)),
      AuCmd("CursorMoved"):buffer(bufnr):callback(vim.lsp.buf.clear_references),
    })
    :set()
  if client.resolved_capabilities.code_lens then
    Group("UserLSPCodeLensRefresh")
      :extend({
        AuCmd("InsertLeave"):buffer(bufnr):callback(wrap(vim.lsp.codelens.refresh)),
        AuCmd("InsertLeave"):buffer(bufnr):callback(wrap(vim.lsp.codelens.display)),
      })
      :set()
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
end

return M
