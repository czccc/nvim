local M = {}

---filter passed to vim.lsp.buf.format
---always selects null-ls if it's available and caches the value per buffer
---@param client table client attached to a buffer
---@return boolean if client matches
function M.format_filter(client)
  local filetype = vim.bo.filetype
  local n = require("null-ls")
  local s = require("null-ls.sources")
  local method = n.methods.FORMATTING
  local available_formatters = s.get_available(filetype, method)

  if #available_formatters > 0 then
    return client.name == "null-ls"
  elseif client.supports_method("textDocument/formatting") then
    return true
  else
    return false
  end
end

function M.enable_format_on_save()
  utils.Group("UserLSPFormatOnSave", { "BufWritePre", "*", wrap(M.format) })
end
function M.disable_format_on_save()
  utils.Group("UserLSPFormatOnSave"):unset()
end

---Provide vim.lsp.buf.format for nvim <0.8
---@param opts table
function M.format(opts)
  opts = opts or { filter = M.format_filter }

  return vim.lsp.buf.format(opts)
end

function M.code_action_listener()
  local lsp_util = vim.lsp.util
  local bufnr = vim.api.nvim_get_current_buf()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics(bufnr, nil, nil, nil) }
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
