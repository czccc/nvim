local M = {}

M.packers = {
  {
    "skywind3000/asyncrun.vim",
    config = function()
      require("plugins.async").setup_async_run()
    end,
    event = "BufRead",
  },
  {
    "skywind3000/asynctasks.vim",
    config = function()
      require("plugins.async").setup_async_tasks()
    end,
    event = "BufRead",
  },
}

M.setup_async_run = function()
  vim.cmd([[ let g:asyncrun_open = 8 ]])
  vim.cmd([[ let g:asyncrun_mode = 'term' ]])
  utils.Key("n", "<Leader>th", "<cmd>AsyncRun zsh<cr>")
  utils.Key("n", "<Leader>tv", "<cmd>AsyncRun -pos=right zsh<cr>")
end

M.setup_async_tasks = function()
  vim.cmd([[ let g:asynctask_template = '~/.config/nvim/task_template.ini' ]])
  vim.cmd([[ let g:asynctasks_extra_config = ['~/.config/nvim/tasks.ini'] ]])
  vim.cmd([[ let g:asynctasks_mode = 'term' ]])
  vim.cmd([[ let g:asynctasks_term_pos = 'bottom' ]])
  vim.cmd([[ let g:asynctasks_term_rows = 10 ]])
  vim.cmd([[ let g:asynctasks_term_reuse = 1 ]])
  utils.Key("n", "<F5>", "<cmd>AsyncTask run<cr>")
  utils.Key("n", "<F6>", "<cmd>AsyncTask build<cr>")
  utils.Key("n", "<F7>", "<cmd>AsyncTaskLast<cr>")
  local task_select = function()
    local tasks = vim.fn["asynctasks#list"]("")
    local max_len = 0
    if not tasks or #tasks == 0 then
      vim.notify("No AsyncTasks.")
      return
    end
    for _, v in ipairs(tasks) do
      if #v.name > max_len then
        max_len = #v.name
      end
    end
    max_len = max_len + 2
    vim.ui.select(tasks, {
      prompt = "Select Tasks:",
      format_item = function(item)
        return string.format("%-" .. max_len .. "s", item.name) .. item.command
      end,
    }, function(choice)
      if choice then
        vim.cmd("AsyncTask " .. choice.name)
      end
    end)
  end
  utils.Key("n", "<F8>", task_select)
  utils.Key("n", "<Leader>st", task_select)
end

M.exector = function(command, cwd)
  cwd = cwd or vim.fn.getcwd()
  vim.cmd(string.format("AsyncRun -cwd=%s -listed=0 %s", cwd, command))
end

M.exector_with_args = function(command, args, cwd)
  cwd = cwd or vim.fn.getcwd()
  command = command .. " " .. table.concat(args, " ")
  vim.cmd(string.format("AsyncRun! -cwd=%s -listed=0 %s", cwd, command))
end

return M
