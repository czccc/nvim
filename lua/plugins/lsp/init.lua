local M = {}

M.packers = {
  {
    "neovim/nvim-lspconfig",
    event = "BufRead",
    opt = true,
    config = function()
      require("plugins.lsp").setup()
    end,
    wants = {
      "null-ls.nvim",
      "neodev.nvim",
      "cmp-nvim-lsp",
      "mason.nvim",
      "mason-lspconfig.nvim",
      -- "vim-illuminate",
    },
    requires = {
      {
        "williamboman/mason.nvim",
      },
      {
        "williamboman/mason-lspconfig.nvim",
      },
      {
        "jose-elias-alvarez/null-ls.nvim",
      },
      {
        "folke/neodev.nvim",
      },
      -- {
      --   "RRethy/vim-illuminate",
      -- },
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

for _, packer in ipairs(require("plugins.lsp.lang").packers) do
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
  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    return cmp_nvim_lsp.default_capabilities()
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  return capabilities
end

function M.common_on_attach(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  if client.supports_method("textDocument/documentHighlight") then
    utils.Group("UserLSPDocumentHighlight" .. bufnr, {
      "CursorHold",
      bufnr,
      wrap(vim.lsp.buf.document_highlight, client.id),
    }, { "CursorMoved", bufnr, vim.lsp.buf.clear_references })
  end
  if client.supports_method("textDocument/codeLens") then
    utils.Group(
      "UserLSPCodeLensRefresh" .. bufnr,
      { { "BufEnter", "InsertLeave" }, bufnr, wrap(vim.lsp.codelens.refresh) },
      { "InsertLeave", bufnr, wrap(vim.lsp.codelens.display) }
    )
  end
  if client.supports_method("textDocument/codeAction") then
    utils.Group(
      "UserLSPCodeAction" .. bufnr,
      { "CursorHold,CursorHoldI", bufnr, require("plugins.lsp.utils").code_action_listener }
    )
  end
  if client.supports_method("textDocument/documentSymbol") then
    local status_ok, navic = pcall(require, "nvim-navic")
    if status_ok then
      navic.attach(client, bufnr)
    end
  end
  if client.supports_method("textDocument/formatting") then
    local format_group = utils.Group("UserLSPFormatOnSave" .. bufnr, {
      "BufWritePre",
      bufnr,
      wrap(require("plugins.lsp.utils").format),
    })
    utils
      .IKey("n", "[of", function()
        format_group:set()
      end, "Format On Save")
      :buffer()
      :set()
    utils
      .IKey("n", "]of", function()
        format_group:unset()
      end, "Format On Save")
      :buffer()
      :set()
  end

  utils.Key("n", "K", vim.lsp.buf.hover, "Show Hover")
  utils.load_wk({
    a = { vim.lsp.buf.range_code_action, "Code Actions" },
    F = { vim.lsp.buf.range_formatting, "Format Code" },
  }, { prefix = "g", mode = "v", opts = { buffer = bufnr } })
  utils.load_wk({
    a = { vim.lsp.buf.code_action, "Code Actions" },
    d = { require("plugins.telescope").lsp_definitions, "Goto Definition" },
    D = { vim.lsp.buf.declaration, "Goto Declaration" },
    I = { require("plugins.telescope").lsp_implementations, "Goto Implementations" },
    -- Key("n", "gs", vim.lsp.buf.signature_help, "Show Signature Help"),
    t = { vim.lsp.buf.type_definition, "Goto Type Definition" },
    l = { wrap(vim.diagnostic.open_float, 0, { scope = "line" }), "Show Line Diagnostics" },
    L = { vim.lsp.codelens.run, "Code Lens" },
    r = { require("plugins.telescope").lsp_references, "Goto References" },
    R = { vim.lsp.buf.rename, "Rename Symbol" },
    p = { wrap(require("plugins.lsp.peek").Peek, "definition"), "Peek Definition" },
    F = { require("plugins.lsp.utils").format, "Format Code" },
    h = { vim.lsp.buf.signature_help, "Show Signature Help" },
  }, { prefix = "g", mode = "n", opts = { buffer = bufnr } })
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

  require("mason").setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })
  require("mason-lspconfig").setup({
    ensure_installed = { "sumneko_lua", "pyright", "yamlls" },
    automatic_installation = true,
  })
  require("plugins.lsp.null-ls").setup()
  -- must be setup after lsp-installer
  require("plugins.lsp.lang").setup()

  local function enable_cursor_diagnostic()
    utils.Group(
      "UserCursorDiagnostic",
      { "CursorHold", "*", wrap(vim.diagnostic.open_float, 0, { focusable = false, scope = "cursor" }) }
    )
  end
  local function disable_cursor_diagnostic()
    utils.Group("UserCursorDiagnostic"):unset()
  end
  enable_cursor_diagnostic()

  utils.Key("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
  utils.Key("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
  utils.Key("n", "[od", enable_cursor_diagnostic, "Cursor Diagnostic")
  utils.Key("n", "]od", disable_cursor_diagnostic, "Cursor Diagnostic")

  utils.load_wk({
    name = "LSP",
    I = { "<cmd>Mason<cr>", "Lsp Installer" },
    i = { "<cmd>LspInfo<cr>", "Lsp Info" },
    r = { "<cmd>LspRestart<cr>", "Lsp Restart" },
    q = { vim.diagnostic.setloclist, "Loc List" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
    S = { "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace Symbols" },
    d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostic" },
    D = { "<cmd>Telescope diagnostics<cr>", "Workspace Diagnostic" },
  }, { prefix = "<Leader>l", mode = "n" })

  utils.Key("n", "<Leader>ui", "<cmd>LspInfo<cr>", "Lsp Info")
  utils.Key("n", "<Leader>uI", "<cmd>NullLsInfo<cr>", "NullLs Info")
end

M.setup_illuminate = function()
  require("illuminate").configure({
    -- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
    filetypes_denylist = {
      "dirvish",
      "fugitive",
      "alpha",
      "NvimTree",
      "neo-tree",
      "packer",
      "neogitstatus",
      "Trouble",
      "lir",
      "Outline",
      "spectre_panel",
      "toggleterm",
      "DressingSelect",
      "TelescopePrompt",
    },
    -- under_cursor: whether or not to illuminate under the cursor
    under_cursor = true,
  })
end

return M
