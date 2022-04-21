local M = {}

M.status = {
  in_process = false,
  round = 1,
  time = 0,
  count = 0,
}

local cal_remain = function(time, count)
  local remain = time * 60 - count
  local r_min = math.floor(remain / 60)
  local r_sec = remain % 60
  return string.format("%02d:%02d", r_min, r_sec)
end

M.get_time = function()
  if M.status.in_process then
    local spinners = { " ", " ", " ", " ", " ", " ", " ", " ", " " }
    local icon = spinners[M.status.count % #spinners + 1]
    return icon .. cal_remain(M.status.time, M.status.count)
  else
    return " " .. os.date("%H:%M")
  end
end

local function update_status(round)
  if round < M.status.round or not M.status.in_process then
    return
  end
  M.status.count = M.status.count + 1
  if M.status.count >= M.status.time * 60 then
    M.status.in_process = false
    M.status.count = 0
    vim.notify("Tomato Clock Finished!", "Info")
  else
    vim.defer_fn(wrap(update_status, round), 1000)
  end
end

M.start = function(opts)
  opts = opts or {}
  opts.time = opts.time or 30
  vim.notify(string.format("Starting Tomato Clock for %d minutes", opts.time), "Info")
  M.status.in_process = true
  M.status.time = opts.time
  M.status.count = 0
  M.status.round = M.status.round + 1
  update_status(M.status.round)
end

return M
