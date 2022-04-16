local M = {}

M.latest_buf_id = nil
M.latest_command = nil

function M.delete_buf(bufnr)
  if bufnr ~= nil then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

function M.split(vertical, bufnr)
  local cmd = vertical and "vsplit" or "split"

  vim.cmd(cmd)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)
end

function M.resize(vertical, amount)
  local cmd = vertical and "vertical resize " or "resize"
  cmd = cmd .. amount

  vim.cmd(cmd)
end

-- local default_opts = {
--   split = "horizontal",
--   size = "50%",
-- }

M.execute = function(command, cwd)
  -- opts = opts or {}
  -- opts = vim.tbl_extend("force", default_opts, opts)

  if M.latest_buf_id ~= nil then
    vim.api.nvim_buf_delete(M.latest_buf_id, { force = true })
  end
  M.latest_buf_id = vim.api.nvim_create_buf(false, true)
  -- local header = {
  --   "Command: " .. command,
  --   "CWD: " .. cwd,
  -- }
  -- vim.api.nvim_buf_set_lines(M.latest_buf_id, 0, -1, false, header)

  M.split(false, M.latest_buf_id)
  M.resize(false, "-15")
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, true, true), "", true)
  vim.api.nvim_buf_set_keymap(M.latest_buf_id, "n", "<Esc>", ":q<CR>", { noremap = true })
  vim.api.nvim_buf_set_keymap(M.latest_buf_id, "n", "<CR>", "i", { noremap = true })
  vim.api.nvim_buf_set_keymap(M.latest_buf_id, "n", "<Tab>", "<C-w>k", { noremap = true })
  vim.api.nvim_buf_set_keymap(M.latest_buf_id, "i", "<C-Tab>", "<C-w>k", { noremap = true })

  -- run the command
  vim.fn.termopen(command, { cwd = cwd })
  M.latest_command = command

  local function onDetach(_, _)
    M.latest_buf_id = nil
  end
  vim.api.nvim_buf_attach(M.latest_buf_id, false, { on_detach = onDetach })
end

M.execute_in_cwd = function(command)
  M.execute(command, vim.fn.getcwd())
end

M.execute_with_args = function(command, args, cwd)
  M.execute(command .. " " .. table.concat(args, " "), cwd)
end

M.execute_in_cwd_with_args = function(command, args)
  M.execute_with_args(command, args, vim.fn.getcwd())
end

M.ui_input = function()
  vim.ui.input("Command:", function(result)
    if result == "" then
      return
    end

    local parts = vim.split(result, " ")
    local command = parts[1]
    local args = {}
    for i = 2, #parts do
      table.insert(args, parts[i])
    end

    M.execute_with_args(command, args, vim.fn.getcwd())
  end)
end

M.repeat_lastest = function()
  if M.latest_command == nil then
    vim.notify("No command to repeat")
    return
  end
  M.execute(M.latest_command, vim.fn.getcwd())
end

return M
