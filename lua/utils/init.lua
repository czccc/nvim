return {
  Path = require("utils.path"),
  IKey = require("utils.key").IKey,
  Key = require("utils.key").Key,
  IAuCmd = require("utils.autocmd").IAuCmd,
  AuCmd = require("utils.autocmd").AuCmd,
  IGroup = require("utils.autocmd").IGroup,
  Group = require("utils.autocmd").Group,

  load = function(maps)
    maps = maps or {}
    for _, map in ipairs(maps) do
      map:set()
    end
  end,

  load_wk = require("utils.key").load_wk,
}
