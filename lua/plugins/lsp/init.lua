local M = {}
local AuCmd = utils.AuCmd
local Group = utils.Group
local Key = utils.Key

M.packers = {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    opt = true,
    config = function()
      require("plugins.lsp").setup()
    end,
    wants = {
      "null-ls.nvim",
      "lua-dev.nvim",
      "cmp-nvim-lsp",
      "nvim-lsp-installer",
    },
    requires = {
      {
        "jose-elias-alvarez/null-ls.nvim",
      },
      {
        "folke/lua-dev.nvim",
        module = "lua-dev",
      },
      {
        "williamboman/nvim-lsp-installer",
      },
      {
        "ray-x/lsp_signature.nvim",
        config = function()
          require("lsp_signature").setup({
            bind = true,
            floating_window = true,
            floating_window_above_cur_line = true,
            hint_enable = true,
            -- hint_prefix = "🐼 ",
            hint_prefix = " ",
            hint_scheme = "String",
            hi_parameter = "Search",
          })
        end,
        event = { "BufRead", "BufNew" },
      },
    },
  },
}

M.config = require("plugins.lsp.config")

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

function M.common_on_exit(_, _)
  Group("UserLSPDocumentHighlight"):unset()
  Group("UserLSPCodeLensRefresh"):unset()
end

function M.common_on_init(_, _)
  Key("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic"):set()
  Key("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic"):set()
  Key("n", "<Leader>li", "<cmd>LspInfo<cr>", "Lsp Info"):set()
  Key("n", "<Leader>lr", "<cmd>LspRestart<cr>", "Lsp Restart"):set()
  Key("n", "<leader>lq", vim.diagnostic.setloclist, "Loc List"):set()
  Key("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols"):set()
  Key("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols"):set()
  Key("n", "<leader>ld", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostic"):set()
  Key("n", "<leader>lD", "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostic"):set()
end

function M.common_on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  -- if client.resolved_capabilities.document_highlight then
  if client.server_capabilities.documentHighlightProvider then
    Group("UserLSPDocumentHighlight")
        :extend({
          AuCmd("CursorHold"):buffer(bufnr):callback(wrap(vim.lsp.buf.document_highlight, client.id)),
          AuCmd("CursorMoved"):buffer(bufnr):callback(vim.lsp.buf.clear_references),
        })
        :set()
  end
  -- if client.resolved_capabilities.code_lens then
  if client.server_capabilities.codeLensProvider then
    Group("UserLSPCodeLensRefresh")
        :extend({
          AuCmd("InsertLeave"):buffer(bufnr):callback(wrap(vim.lsp.codelens.refresh)),
          AuCmd("InsertLeave"):buffer(bufnr):callback(wrap(vim.lsp.codelens.display)),
        })
        :set()
  end
  if client.server_capabilities.codeActionProvider and client.server_capabilities.codeActionProvider.resolveProvider
  then
    Group("UserLSPCodeAction")
        :cmd("CursorHold,CursorHoldI", "*", require("plugins.lsp.utils").code_action_listener)
        :set()
  end
  Group("UserCursorDiagnostic")
      :cmd("CursorHold")
      :buffer(bufnr)
      :callback(wrap(vim.diagnostic.open_float, 0, { focusable = false, scope = "cursor" }))
      :set()
  Group("UserLSPFormatOnSave"):cmd("BufWritePre", "*", wrap(require("plugins.lsp.utils").format)):set()

  utils.load({
    Key("n", "K", vim.lsp.buf.hover, "Show Hover"):buffer(bufnr),
    Key("n", "ga", vim.lsp.buf.code_action, "Code Actions"):buffer(bufnr),
    Key("v", "ga", vim.lsp.buf.range_code_action, "Code Actions"):buffer(bufnr),
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
    Key("n", "gF", require("plugins.lsp.utils").format, "Format Code"):buffer(bufnr),
    Key("v", "gF", vim.lsp.buf.range_formatting, "Format Code"):buffer(bufnr),
    Key("n", "gh", vim.lsp.buf.signature_help, "Show Signature Help"):buffer(bufnr),
  })
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
  vim.fn.sign_define("CodeActionBulk", { texthl = "DiagnosticSignWarn", text = "", numhl = "DiagnosticSignWarn" })

  vim.diagnostic.config(M.config.diagnostics)
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, M.config.float)
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, M.config.float)

  require("plugins.lsp.null-ls").setup()
  require("nvim-lsp-installer").on_server_ready(function(server)
    require("plugins.lsp.manager").setup(server.name, nil)
  end)
  utils.Key("n", "<Leader>l"):group("LSP"):set()
  utils.Key("n", "<Leader>lI", "<cmd>LspInstallInfo<cr>", "Lsp Installer"):set()
end

return M
