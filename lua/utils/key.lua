local M = {}
local Key = {}
function Key.new()
  local inner = {
    mode = "",
    lhs = "",
    rhs = nil,
    group = nil,
    opts = {
      remap = nil,
      silent = true,
      expr = nil,
      nowait = nil,
      buffer = nil,
      desc = nil,
    },
  }
  local o = {}
  o.inner = inner
  setmetatable(o, {
    __index = Key,
    __tostring = function(x)
      local t = x.inner
      local mode_str = type(t.mode) == "string" and t.mode or table.concat(t.mode, ",")
      local rhs_str = type(t.rhs) == "string" and t.rhs or type(t.rhs) == "function" and "<function>" or "nil"
      local opts_str = {}
      for k, v in pairs(t.opts) do
        if type(v) == "boolean" then
          table.insert(opts_str, k)
        elseif type(v) == "string" then
          table.insert(opts_str, string.format('%s="%s"', k, v))
        elseif type(v) == "number" then
          table.insert(opts_str, string.format("%s=%d", k, v))
        end
      end
      if t.group then
        table.insert(opts_str, string.format('group="%s"', t.group))
      end
      local s = string.format('Key("%s", "%s", "%s", { %s })', mode_str, t.lhs, rhs_str, table.concat(opts_str, ", "))
      return s
    end,
  })
  return o
end
function Key:mode(mode)
  self.inner.mode = mode
  return self
end
function Key:lhs(lhs)
  self.inner.lhs = lhs
  return self
end
function Key:rhs(rhs)
  self.inner.rhs = rhs
  return self
end
function Key:opts(opts)
  if opts and type(opts) == "table" then
    if opts.noremap then
      self:noremap()
    end
    if opts.remap then
      self:remap()
    end
    if opts.nosilent then
      self:nosilent()
    end
    if opts.silent then
      self:silent()
    end
    if opts.expr then
      self:expr()
    end
    if opts.nowait then
      self:nowait()
    end
    if opts.buffer then
      self:buffer()
    end
    if opts.desc then
      self:desc(opts.desc)
    end
  end
  return self
end
function Key:group(group)
  self.inner.group = group
  return self
end
function Key:noremap()
  self.inner.opts.remap = nil
  return self
end
function Key:remap()
  self.inner.opts.remap = true
  return self
end
function Key:nosilent()
  self.inner.opts.silent = nil
  return self
end
function Key:silent()
  self.inner.opts.silent = true
  return self
end
function Key:expr()
  self.inner.opts.expr = true
  return self
end
function Key:nowait()
  self.inner.opts.nowait = true
  return self
end
function Key:buffer(bufnr)
  bufnr = bufnr or 0
  self.inner.opts.buffer = bufnr
  return self
end
function Key:desc(desc)
  self.inner.opts.desc = desc
  return self
end

function Key:set()
  local key = self.inner
  if
    not key.opts.buffer
    and M.keys[key.mode]
    and M.keys[key.mode][key.lhs]
    and tostring(self) ~= tostring(M.keys[key.mode][key.lhs])
  then
    vim.notify(
      "Key already exists!\n\tOld: " .. tostring(self) .. "\n\tNew: " .. tostring(M.keys[key.mode][key.lhs]),
      "WARN"
    )
  elseif not key.opts.buffer and not key.group then
    M.keys[key.mode] = M.keys[key.mode] or {}
    M.keys[key.mode][key.lhs] = self
  end
  if key.group then
    local status_ok, wk = pcall(require, "which-key")
    if not status_ok then
      return
    end
    local tmp = {}
    tmp[key.lhs] = { name = key.group }
    wk.register(tmp, { mode = key.mode })
  else
    if key.rhs then
      vim.keymap.set(key.mode, key.lhs, key.rhs, key.opts)
    elseif key.opts.desc then
      local status_ok, wk = pcall(require, "which-key")
      if not status_ok then
        return
      end
      local tmp = {}
      tmp[key.lhs] = { key.opts.desc }
      wk.register(tmp, { mode = key.mode })
    else
      vim.keymap.del(key.mode, key.lhs)
    end
  end
end

M.keys = {}

M.Key = function(mode, lhs, rhs, opts)
  local key = Key.new()
  if mode then
    key:mode(mode)
  end
  if lhs then
    key:lhs(lhs)
  end
  if rhs then
    key:rhs(rhs)
  end
  if opts and type(opts) == "string" then
    key:desc(opts)
  else
    key:opts(opts)
  end
  return key
end

M.ScoopKey = function(mode, prefix, oopts)
  mode = mode or "n"
  prefix = prefix or ""
  oopts = oopts or {}
  local prefix_func = function(lhs, rhs, opts)
    lhs = string.format("%s%s", prefix, lhs)
    return M.Key(mode, lhs, rhs, opts):opts(oopts)
  end
  return prefix_func
end

M.PrefixKey = function(prefix)
  local prefix_func = function(mode, lhs, rhs, opts)
    lhs = string.format("%s%s", prefix, lhs)
    return M.Key(mode, lhs, rhs, opts)
  end
  return prefix_func
end

M.PrefixModeKey = function(prefix, mode)
  local prefix_func = function(lhs, rhs, opts)
    mode = mode or "n"
    lhs = string.format("%s%s", prefix, lhs)
    return M.Key(mode, lhs, rhs, opts)
  end
  return prefix_func
end

M.load = function(keymaps)
  keymaps = keymaps or {}
  for _, key in ipairs(keymaps) do
    key:set()
  end
end

-- M.load_from_wk = function(keymaps, opts)
--   keymaps = keymaps or {}
--   local FuncKey = M.Key
--   if opts.prefix then
--     FuncKey = M.PrefixKey(opts.prefix)
--   end
--   local mode = opts.mode or "n"
--   for key, val in pairs(keymaps) do
--     FuncKey(mode, key, key.rhs):set()
--   end
-- end

return M
