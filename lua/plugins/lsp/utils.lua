local M = {}

---filter passed to vim.lsp.buf.format
---gives higher priority to null-ls
---@param clients table clients attached to a buffer
---@return table chosen clients
function M.format_filter(clients)
  return vim.tbl_filter(function(client)
    local status_ok, formatting_supported = pcall(function()
      return client.supports_method("textDocument/formatting")
    end)
    -- give higher prio to null-ls
    if status_ok and formatting_supported and client.name == "null-ls" then
      return "null-ls"
    else
      return status_ok and formatting_supported and client.name
    end
  end, clients)
end

---Provide vim.lsp.buf.format for nvim <0.8
---@param opts table
function M.format(opts)
  opts = opts or { filter = M.format_filter }

  if vim.lsp.buf.format then
    vim.lsp.buf.format(opts)
  end

  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  local clients = vim.lsp.buf_get_clients(bufnr)

  if opts.filter then
    clients = opts.filter(clients)
  elseif opts.id then
    clients = vim.tbl_filter(function(client)
      return client.id == opts.id
    end, clients)
  elseif opts.name then
    clients = vim.tbl_filter(function(client)
      return client.name == opts.name
    end, clients)
  end

  clients = vim.tbl_filter(function(client)
    return client.supports_method("textDocument/formatting")
  end, clients)

  if #clients == 0 then
    vim.notify("[LSP] Format request failed, no matching language servers.")
  end

  local timeout_ms = opts.timeout_ms or 1000
  for _, client in pairs(clients) do
    local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
    local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
    if result and result.result then
      vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
    elseif err then
      vim.notify(string.format("[LSP][%s] %s", client.name, err), vim.log.levels.WARN)
    end
  end
end

function M.code_action_listener()
  local lsp_util = vim.lsp.util
  local bufnr = vim.api.nvim_get_current_buf()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local params = lsp_util.make_range_params()
  params.context = context
  local callback = function(res)
    local has_actions = false
    for _, result in pairs(res) do
      if result.result and next(result.result) ~= nil then
        has_actions = true
        break
      end
    end
    vim.fn.sign_unplace("code_action_listener")
    if has_actions then
      vim.fn.sign_place(
        params.range.start.line + 1,
        "code_action_listener",
        "CodeActionBulk",
        bufnr,
        { lnum = params.range.start.line + 1, priority = 10 }
      )
    end
  end
  vim.lsp.buf_request_all(bufnr, "textDocument/codeAction", params, callback)
end

return M
