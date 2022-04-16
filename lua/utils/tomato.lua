local M = {}

local default_config = {
  work_time = 25,
  rest_time = 5,
}

M.config = default_config

M.status = {
  in_process = false,
  work = true,
  time = 0,
  count = 0,
}

M.setup = function(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", opts, default_config)
end

M.start_work = function()
  M.status.in_process = true
  M.status.work = true
  M.status.time = M.config.work_time
  M.status.count = 0
end

M.start_rest = function()
  M.status.in_process = true
  M.status.work = false
  M.status.time = M.config.rest_time
  M.status.count = 0
end

M.switch_status = function()
  if M.status.work then
    M.start_rest()
  else
    M.start_work()
  end
end

M.start = function()
  if M.status.in_process then
    vim.notify(
      string.format("Already started! Continue %s for %d minutes!", M.status.work and "work" or "rest", M.status.time),
      "Info"
    )
    return
  end
  vim.notify("Starting Tomato Clock", "Info")
  local timer = vim.loop.new_timer()
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      M.status.count = M.status.count + 1
      if M.status.time * 60 <= M.status.count then
        timer:close()
        M.stop()
        return
      end
      vim.notify("Starting Pomodoro", "Info")
    end)
  )
end

return M
