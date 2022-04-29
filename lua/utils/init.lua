local M = {}

M.Path = require("utils.path")
M.Key = require("utils.key").Key
M.AuCmd = require("utils.autocmd").AuCmd
M.Group = require("utils.autocmd").Group

M.load = function(maps)
  maps = maps or {}
  for _, map in ipairs(maps) do
    map:set()
  end
end

return M
