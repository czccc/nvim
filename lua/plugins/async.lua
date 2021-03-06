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
end

M.setup_async_tasks = function()
  vim.cmd([[ let g:asynctask_template = '~/.config/nvim/task_template.ini' ]])
  vim.cmd([[ let g:asynctasks_extra_config = ['~/.config/nvim/tasks.ini'] ]])
  vim.cmd([[ let g:asynctasks_mode = 'term' ]])
  vim.cmd([[ let g:asynctasks_term_pos = 'bottom' ]])
  vim.cmd([[ let g:asynctasks_term_rows = 10 ]])
  vim.cmd([[ let g:asynctasks_term_reuse = 1 ]])
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
