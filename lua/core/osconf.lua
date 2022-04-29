local M = {}
local path = require("utils.path")

M.setup = function()
  if path.is_windows then
    local sqlite_path = path.join(path.home_dir, "PATH", "sqlite3.dll")
    if not path.is_file(sqlite_path) then
      vim.notify("Sqlite dll not found! Download from https://www.sqlite.org/download.html")
    end
    vim.g.sqlite_clib_path = sqlite_path

    local neotree = require("plugins.neotree")
    neotree.config.filesystem.filtered_items.hide_gitignored = false
    neotree.config.filesystem.follow_current_file = false
    neotree.config.filesystem.use_libuv_file_watcher = false
  end
  if path.is_wsl then
    vim.cmd([[
        let g:clipboard = {
              \   'name': 'win32yank-wsl',
              \   'copy': {
              \      '+': 'win32yank.exe -i --crlf',
              \      '*': 'win32yank.exe -i --crlf',
              \    },
              \   'paste': {
              \      '+': 'win32yank.exe -o --lf',
              \      '*': 'win32yank.exe -o --lf',
              \   },
              \   'cache_enabled': 0,
              \ }
    ]])
  end
  if path.is_mac then
    local Key = utils.Key
    Key("n", "<A-Up>", ":resize -2<CR>", "Resize Up"):set()
    Key("n", "<A-Down>", ":resize +2<CR>", "Resize Down"):set()
    Key("n", "<A-Left>", ":vertical resize -2<CR>", "Resize Left"):set()
    Key("n", "<A-Right>", ":vertical resize +2<CR>", "Resize Right"):set()
  end
end

return M
