local M = {}

function _G.dump(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(table.unpack(objects))
end

function _G.wrap(func, ...)
  local args = { ... }
  return function()
    func(table.unpack(args))
  end
end

local path_sep = vim.loop.os_uname().version:match("Windows") and "\\" or "/"
function _G.join_paths(...)
  local result = table.concat({ ... }, path_sep)
  return result
end

function _G.require_clean(module)
  package.loaded[module] = nil
  _G[module] = nil
  local _, requested = pcall(require, module)
  return requested
end

_G.utils = require("utils")

_G.table.unpack = table.unpack or unpack

return M
