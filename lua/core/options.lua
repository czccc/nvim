local M = {}
local path = require("utils.path")

M.disabled_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}

M.gopts = {
  mapleader = " ",
  maplocalleader = " ",
}

M.opts = {
  backup = false, -- creates a backup file
  clipboard = "unnamedplus", -- allows neovim to access the system clipboard
  cmdheight = 1, -- more space in the neovim command line for displaying messages
  colorcolumn = "99999", -- fixes indentline for now
  completeopt = { "menuone", "noselect" },
  conceallevel = 0, -- so that `` is visible in markdown files
  fileencoding = "utf-8", -- the encoding written to a file
  fileformats = "unix,mac,dos",
  foldexpr = "", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
  foldmethod = "manual", -- folding, set to "expr" for treesitter based folding
  -- foldexpr = "nvim_treesitter#foldexpr()",
  -- foldmethod = "expr",
  -- foldlevel = 4,
  -- foldtext =
  --     [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend)) . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']],
  -- foldnestmax = 3,
  -- foldminlines = 1,
  guifont = "FiraCode Nerd Font:h13", -- the font used in graphical neovim applications
  hidden = true, -- required to keep multiple buffers and open multiple buffers
  hlsearch = true, -- highlight all matches on previous search pattern
  ignorecase = true, -- ignore case in search patterns
  mouse = "a", -- allow the mouse to be used in neovim
  pumheight = 10, -- pop up menu height
  showmode = false, -- we don't need to see things like -- INSERT -- anymore
  showtabline = 2, -- always show tabs
  smartcase = true, -- smart case
  smartindent = true, -- make indenting smarter again
  splitbelow = true, -- force all horizontal splits to go below current window
  splitright = true, -- force all vertical splits to go to the right of current window
  swapfile = false, -- creates a swapfile
  termguicolors = true, -- set term gui colors (most terminals support this)
  timeoutlen = 150, -- time to wait for a mapped sequence to complete (in milliseconds)
  title = true, -- set the title of window to the value of the titlestring
  -- opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
  undodir = path.join(path.cache_dir, "undo"), -- set an undo directory
  undofile = true, -- enable persistent undo
  updatetime = 300, -- faster completion
  writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
  expandtab = true, -- convert tabs to spaces
  shiftwidth = 2, -- the number of spaces inserted for each indentation
  tabstop = 2, -- insert 2 spaces for a tab
  smarttab = true,
  cursorline = true, -- highlight the current line
  cursorcolumn = false,
  number = true, -- set numbered lines
  relativenumber = false, -- set relative numbered lines
  numberwidth = 4, -- set number column width to 2 {default 4}
  signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
  wrap = false, -- display lines as one long line
  spell = false,
  spelllang = "en",
  spellfile = path.join(path.config_dir, "spell", "en.utf-8.add"),
  shadafile = path.join(path.cache_dir, "nvim.shada"),
  scrolloff = 1, -- minimal number of screen lines to keep above and below the cursor.
  sidescrolloff = 1, -- minimal number of screen lines to keep left and right of the cursor.

  -- newly added
  autoread = true,
  wrapscan = true, -- Searches wrap around the end of the file
  pumblend = 0,
  joinspaces = false,
  -- autowriteall = true,
  grepprg = "rg --hidden --vimgrep --smart-case --",
  grepformat = "%f:%l:%c:%m",
  list = true,
  listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←",
  jumpoptions = "stack",
  diffopt = "filler,iwhite,internal,algorithm:patience",
  viewoptions = "folds,cursor,curdir,slash,unix",
  sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal",
  -- sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal",
  history = 2000,
  wildignorecase = true,
  wildignore = {
    "*.aux,*.out,*.toc",
    "*.o,*.obj,*.dll,*.jar,*.pyc,__pycache__,*.rbc,*.class",
    -- media
    "*.ai,*.bmp,*.gif,*.ico,*.jpg,*.jpeg,*.png,*.psd,*.webp",
    "*.avi,*.m4a,*.mp3,*.oga,*.ogg,*.wav,*.webm",
    "*.eot,*.otf,*.ttf,*.woff",
    "*.doc,*.pdf",
    -- archives
    "*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz",
    -- temp/system
    "*.*~,*~ ",
    "*.swp,.lock,.DS_Store,._*,tags.lock",
    -- version control
    ".git,.svn",
  },
  shortmess = "aoOTIcF",
  whichwrap = "<,>,[,],h,l",
}

M.wopts = {
  -- foldexpr = "", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
  -- foldmethod = "manual", -- folding, set to "expr" for treesitter based folding
  foldexpr = "nvim_treesitter#foldexpr()",
  foldmethod = "expr",
  foldlevel = 5,
  -- foldtext = [[substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend)) . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']],
  -- fillchars = "fold:\\",
  -- foldnestmax = 5,
  foldminlines = 1,
}

function M.setup()
  if #vim.api.nvim_list_uis() == 0 then
    vim.opt.shortmess = "" -- try to prevent echom from cutting messages off or prompting
    vim.opt.more = false -- don't pause listing when screen is filled
    vim.opt.cmdheight = 9999 -- helps avoiding |hit-enter| prompts.
    vim.opt.columns = 9999 -- set the widest screen possible
    vim.opt.swapfile = false -- don't use a swap file
    return
  end
  for k, v in pairs(M.gopts) do
    vim.g[k] = v
  end
  for _, plugin in pairs(M.disabled_plugins) do
    vim.g["loaded_" .. plugin] = 1
  end
  for k, v in pairs(M.opts) do
    vim.opt[k] = v
  end
  -- TODO: fix unknown fold issue when using tab as indent
  vim.cmd(
    [[set foldtext=substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').'...'.trim(getline(v:foldend)).'\ ('.(v:foldend-v:foldstart+1).'\ lines)'.repeat('\ ',300)]]
  )
  -- set blink cursor
  vim.cmd([[set guicursor+=a:-blinkwait5-blinkoff5-blinkon5]])
  for k, v in pairs(M.wopts) do
    vim.wo[k] = v
  end
end

return M
