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

M.lang_files = {
  "plugins.lsp.lang.clangd",
  "plugins.lsp.lang.go",
  "plugins.lsp.lang.json",
  "plugins.lsp.lang.lua",
  "plugins.lsp.lang.markdown",
  "plugins.lsp.lang.rust",
  "plugins.lsp.lang.yaml",
}
for _, packer in ipairs(require("plugins").merge(M.lang_files)) do
  table.insert(M.packers, packer)
end

M.config = {
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
      },
    },
    virtual_text = true,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      format = function(d)
        local t = vim.deepcopy(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          t.message = string.format("%s [%s]", t.message, code):gsub("1. ", "")
        end
        return t.message
      end,
    },
  },
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
  },
}

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

function M.common_on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  local cap = client.server_capabilities
  if cap.documentHighlightProvider then
    Group("UserLSPDocumentHighlight")
      :extend({
        AuCmd("CursorHold"):buffer(bufnr):callback(wrap(vim.lsp.buf.document_highlight, client.id)),
        AuCmd("CursorMoved"):buffer(bufnr):callback(vim.lsp.buf.clear_references),
      })
      :set()
  end
  if cap.codeLensProvider then
    Group("UserLSPCodeLensRefresh")
      :extend({
        AuCmd("InsertLeave"):buffer(bufnr):callback(wrap(vim.lsp.codelens.refresh)),
        AuCmd("InsertLeave"):buffer(bufnr):callback(wrap(vim.lsp.codelens.display)),
      })
      :set()
  end
  -- if cap.codeActionProvider and cap.codeActionProvider.resolveProvider then
  -- if cap.codeActionProvider then
  if client.supports_method("textDocument/codeAction") then
    Group("UserLSPCodeAction")
      :cmd("CursorHold,CursorHoldI")
      :buffer(bufnr)
      :callback(require("plugins.lsp.utils").code_action_listener)
      :set()
  end
  require("plugins.lsp.utils").enable_format_on_save()

  local mapping = {
    Key("n", "K", vim.lsp.buf.hover, "Show Hover"),
    Key("n", "ga", vim.lsp.buf.code_action, "Code Actions"),
    Key("v", "ga", vim.lsp.buf.range_code_action, "Code Actions"),
    Key("n", "gd", require("plugins.telescope").lsp_definitions, "Goto Definition"),
    Key("n", "gD", vim.lsp.buf.declaration, "Goto Declaration"),
    Key("n", "gI", require("plugins.telescope").lsp_implementations, "Goto Implementations"),
    -- Key("n", "gs", vim.lsp.buf.signature_help, "Show Signature Help"),
    Key("n", "gt", vim.lsp.buf.type_definition, "Goto Type Definition"),
    Key("n", "gl", wrap(vim.diagnostic.open_float, 0, { scope = "line" }), "Show Line Diagnostics"),
    Key("n", "gL", vim.lsp.codelens.run, "Code Lens"),
    Key("n", "gr", require("plugins.telescope").lsp_references, "Goto References"),
    Key("n", "gR", vim.lsp.buf.rename, "Rename Symbol"),
    Key("n", "gp", wrap(require("plugins.lsp.peek").Peek, "definition"), "Peek Definition"),
    Key("n", "gF", require("plugins.lsp.utils").format, "Format Code"),
    Key("v", "gF", vim.lsp.buf.range_formatting, "Format Code"),
    Key("n", "gh", vim.lsp.buf.signature_help, "Show Signature Help"),
  }
  for _, m in pairs(mapping) do
    m:buffer(bufnr):set()
  end
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
  require("nvim-lsp-installer").setup({})
  for _, file in ipairs(M.lang_files) do
    local status, lang = pcall(require, file)
    if status and lang.lsp_setup then
      lang.lsp_setup()
    end
  end

  local function enable_cursor_diagnostic()
    Group("UserCursorDiagnostic")
      :cmd("CursorHold", "*", wrap(vim.diagnostic.open_float, 0, { focusable = false, scope = "cursor" }))
      :set()
  end
  local function disable_cursor_diagnostic()
    Group("UserCursorDiagnostic"):unset()
  end
  enable_cursor_diagnostic()

  local mapping = {
    Key("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic"),
    Key("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic"),
    Key("n", "[od", enable_cursor_diagnostic, "Cursor Diagnostic"),
    Key("n", "]od", disable_cursor_diagnostic, "Cursor Diagnostic"),
    Key("n", "[of", require("plugins.lsp.utils").enable_format_on_save, "Format On Save"),
    Key("n", "]of", require("plugins.lsp.utils").disable_format_on_save, "Format On Save"),

    Key("n", "<Leader>l"):group("LSP"),
    Key("n", "<Leader>lI", "<cmd>LspInstallInfo<cr>", "Lsp Installer"),
    Key("n", "<Leader>li", "<cmd>LspInfo<cr>", "Lsp Info"),
    Key("n", "<Leader>lr", "<cmd>LspRestart<cr>", "Lsp Restart"),
    Key("n", "<leader>lq", vim.diagnostic.setloclist, "Loc List"),
    Key("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols"),
    Key("n", "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols"),
    Key("n", "<leader>ld", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostic"),
    Key("n", "<leader>lD", "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostic"),
    Key("n", "<Leader>ui", "<cmd>LspInfo<cr>", "Lsp Info"),
    Key("n", "<Leader>uI", "<cmd>NullLsInfo<cr>", "NullLs Info"),
  }
  for _, m in pairs(mapping) do
    m:set()
  end
end

return M
