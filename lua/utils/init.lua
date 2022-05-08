return {
  Path = require("utils.path"),
  Key = require("utils.key").Key,
  AuCmd = require("utils.autocmd").AuCmd,
  Group = require("utils.autocmd").Group,
  load = function(maps)
    maps = maps or {}
    for _, map in ipairs(maps) do
      map:set()
    end
  end,
}
