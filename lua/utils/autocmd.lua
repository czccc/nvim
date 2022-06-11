local M = {}

local AuCmd = {}
function AuCmd.new()
  local inner = {
    event = nil,
    opts = {
      group = nil,
      pattern = nil,
      buffer = nil,
      desc = nil,
      callback = nil,
      command = nil,
      once = nil,
      nested = nil,
    },
  }
  local o = {}
  o.inner = inner
  setmetatable(o, {
    __index = AuCmd,
    __tostring = function(x)
      local t = x.inner
      local event_str = type(t.event) == "string" and t.event or table.concat(t.event, ",")
      local opts_str = {}
      for k, v in pairs(t.opts) do
        if type(v) == "boolean" then
          table.insert(opts_str, k)
        elseif type(v) == "string" then
          table.insert(opts_str, string.format('%s="%s"', k, v))
        elseif type(v) == "number" then
          table.insert(opts_str, string.format("%s=%d", k, v))
        elseif type(v) == "function" then
          table.insert(opts_str, string.format("%s=<function>", k, v))
        end
      end
      local s = string.format('AuCmd("%s", { %s })', event_str, table.concat(opts_str, ", "))
      return s
    end,
  })
  return o
end

function AuCmd:event(event)
  self.inner.event = event
  return self
end

function AuCmd:group(group)
  self.inner.opts.group = group
  return self
end

function AuCmd:pattern(pattern)
  if self.inner.opts.buffer then
    error(
      string.format(
        "Unable set pattern option, buffer is already set:\n%s\n%s",
        tostring(self),
        vim.inspect(vim.fn.eval("v:errmsg"))
      )
    )
  end
  if pattern == "buffer" then
    self.inner.opts.buffer = 0
  elseif type(pattern) == "number" then
    self.inner.opts.buffer = pattern
  else
    self.inner.opts.pattern = pattern
  end
  return self
end

function AuCmd:buffer(buffer)
  if self.inner.opts.pattern then
    error(
      string.format(
        "Unable set buffer option, pattern is already set:\n%s\n%s",
        tostring(self),
        vim.inspect(vim.fn.eval("v:errmsg"))
      )
    )
  end
  self.inner.opts.buffer = buffer
  return self
end

function AuCmd:desc(desc)
  self.inner.opts.desc = desc
  return self
end

function AuCmd:callback(callback)
  if self.inner.opts.command then
    error(
      string.format(
        "Unable set callback option, command is already set:\n%s\n%s",
        tostring(self),
        vim.inspect(vim.fn.eval("v:errmsg"))
      )
    )
  end
  self.inner.opts.callback = callback
  return self
end

function AuCmd:command(command)
  if self.inner.opts.callback then
    error(
      string.format(
        "Unable set command option, callback is already set:\n%s\n%s",
        tostring(self),
        vim.inspect(vim.fn.eval("v:errmsg"))
      )
    )
  end
  self.inner.opts.command = command
  return self
end

function AuCmd:once()
  self.inner.opts.once = true
  return self
end

function AuCmd:nested()
  self.inner.opts.nested = true
  return self
end

function AuCmd:opts(opts)
  opts = opts or {}
  if opts.group then
    self:group(opts.group)
  end
  if opts.pattern then
    self:pattern(opts.pattern)
  end
  if opts.buffer then
    self:buffer(opts.buffer)
  end
  if opts.desc then
    self:desc(opts.desc)
  end
  if opts.callback then
    self:callback(opts.callback)
  end
  if opts.command then
    self:command(opts.command)
  end
  if opts.once then
    self:once()
  end
  if opts.nested then
    self:nested()
  end
  return self
end

function AuCmd:set()
  local t = self.inner
  vim.api.nvim_create_autocmd(t.event, t.opts)
end

local AuGroup = {}

function AuGroup.new()
  local inner = {
    name = "",
    clear = true,
    cmds = {},
  }
  local o = {}
  o.inner = inner
  setmetatable(o, {
    __index = AuGroup,
    __tostring = function(x)
      local t = x.inner
      return string.format('AuGroup("%s", {\n\t%s\n})', t.name, table.concat(tostring(t.cmds), "\n\t"))
    end,
  })
  return o
end

function AuGroup:name(name)
  self.inner.name = name
  return self
end

function AuGroup:noclear()
  self.inner.clear = false
  return self
end

function AuGroup:cmd(event, pattern, command, opts)
  local t = self.inner
  local group = vim.api.nvim_create_augroup(t.name, { clear = t.clear })
  local cmd = M.AuCmd(event, pattern, command, opts):group(group)
  return cmd
end

function AuGroup:cmds(cmds)
  for _, opt in ipairs(cmds) do
    local t = self.inner
    local group = vim.api.nvim_create_augroup(t.name, { clear = t.clear })
    local cmd = M.AuCmd(table.unpack(opt)):group(group)
    table.insert(self.inner.cmds, cmd)
  end
  return self
end

function AuGroup:add(cmd)
  table.insert(self.inner.cmds, cmd)
  return self
end

function AuGroup:extend(cmds)
  for _, cmd in ipairs(cmds) do
    self:add(cmd)
  end
  return self
end

function AuGroup:set()
  local t = self.inner
  local group = vim.api.nvim_create_augroup(t.name, { clear = t.clear })
  for _, cmd in ipairs(t.cmds) do
    cmd:group(group):set()
  end
end

function AuGroup:unset()
  local t = self.inner
  local status, _ = pcall(vim.api.nvim_del_augroup_by_name, t.name)
  if not status then
    vim.notify("Failed to delete group: " .. t.name, "WARN")
  end
end

M.AuCmd = function(event, pattern, command, opts)
  local cmd = AuCmd.new()
  if event then
    cmd:event(event)
  end
  if pattern then
    cmd:pattern(pattern)
  end
  if command then
    if type(command) == "function" then
      cmd:callback(command)
    else
      cmd:command(command)
    end
  end
  if opts then
    cmd:opts(opts)
  end
  return cmd
end

M.Group = function(name)
  local group = AuGroup.new()
  if name then
    group:name(name)
  end
  return group
end

return M
