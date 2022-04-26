local M = {}
local path = require("utils.path")
local Log = require("core.log")
local Key = require("utils").Key

M.keys = {
  -- insert mode
  Key("i", "<C-a>", "<Esc>ggVG", "Select All"),
  Key("i", "<C-s>", "<Esc><cmd>w<CR>", "Write"),
  -- Key("i", "<C-z>", "<C-G>u<C-o>u", "Undo"),
  Key("i", "<C-u>", "<C-G>u<C-u>", "Delete Before"),
  Key("i", "<C-w>", "<C-G>u<C-w>", "Delete Word"),
  Key("i", "jj", "<Esc>"),
  Key("i", "jk", "<Esc>"),
  Key("i", "kj", "<Esc>"),
  Key("i", "<A-j>", "<Esc>:m .+1<CR>==gi", "Move Line Down"),
  Key("i", "<A-k>", "<Esc>:m .-2<CR>==gi", "Move Line Up"),
  Key("i", "<A-Left>", "<C-\\><C-N><C-w>h", "Navigate Left"),
  Key("i", "<A-Down>", "<C-\\><C-N><C-w>j", "Navigate Down"),
  Key("i", "<A-Up>", "<C-\\><C-N><C-w>k", "Navigate Up"),
  Key("i", "<A-Right>", "<C-\\><C-N><C-w>l", "Navigate Right"),

  -- normal mode
  Key("n", "<C-a>", "ggVG", "Select All"),
  Key("n", "<C-s>", ":w<CR>", "Write"),
  Key("n", "<Esc>", ":noh<CR>", "No Highlight"),
  Key("n", "D", "d$"),
  Key("n", "Y", "y$"),
  -- Key("v", "p", [["0p]]),
  -- Key("v", "P", [["0P]]),
  Key("v", "p", [["_dP]]),
  Key("n", "s", "viw"),
  Key("v", "s", [["-c]]),
  Key({ "n", "v" }, "c", [["-c]]),
  Key({ "n", "v" }, "x", [["-x]]),
  Key("n", "j", "gj"),
  Key("n", "k", "gk"),
  Key("n", "gj", "j"),
  Key("n", "gk", "k"),
  Key("n", "<C-h>", "<C-w>h", "Navigate Left"),
  Key("n", "<C-j>", "<C-w>j", "Navigate Down"),
  Key("n", "<C-k>", "<C-w>k", "Navigate Up"),
  Key("n", "<C-l>", "<C-w>l", "Navigate Right"),
  Key("n", "<C-Up>", ":resize -2<CR>", "Resize Up"),
  Key("n", "<C-Down>", ":resize +2<CR>", "Resize Down"),
  Key("n", "<C-Left>", ":vertical resize -2<CR>", "Resize Left"),
  Key("n", "<C-Right>", ":vertical resize +2<CR>", "Resize Right"),
  Key("n", "<A-j>", ":m .+1<CR>==", "Move Line Down"),
  Key("n", "<A-k>", ":m .-2<CR>==", "Move Line Up"),

  -- Which-Key Groups
  Key("n", "<Leader>"):group("Leader"),
  Key("n", "["):group("Previous Move"),
  Key("n", "]"):group("Next Move"),
  Key("n", "g"):group("Goto"),
  Key("n", "z"):group("Fold"),

  Key("n", "<C-y>"):desc("Scroll UP Little"),
  Key("n", "<C-u>"):desc("Scroll UP Much"),
  Key("n", "<C-b>"):desc("Scroll UP Page"),
  Key("n", "<C-e>"):desc("Scroll Down Little"),
  Key("n", "<C-d>"):desc("Scroll Down Much"),
  Key("n", "<C-f>"):desc("Scroll Down Page"),
  Key("n", "<C-\\>"):desc("Terminal"),

  Key("n", "<Leader>=", "<C-w>=", "Resize Windows"),
  Key("n", "<Leader>w", ":w!<CR>", "Save"),
  Key("n", "<Leader>q", ":q!<CR>", "Force Quit"),
  Key("n", "<Leader>Q", ":wqa<CR>", "Quit"),
  Key("n", "<Leader>h", ":nohlsearch<CR>", "No Highlight"),
  Key("n", "<Leader>v"):group("View"),
  Key("n", "<Leader>t"):group("Terminal"),
  Key("n", "<Leader>m"):group("Module"),
  Key("n", "<Leader>u"):group("Utils"),
  Key("n", "<Leader>ui", function()
    require("core.info").toggle_popup(vim.bo.filetype)
  end, "Infos"),
  Key("n", "<Leader>up", function()
    require("utils.startup").setup({ print = true })
  end, "Startup Time"),
  Key("n", "<Leader>vh", ":checkhealth<CR>", "Check Health"),
  Key("n", "<Leader>vH", ":checktime<CR>", "Check Time"),
  Key("n", "<Leader>vm", ":messages<CR>", "Messages"),
  Key("n", "<Leader>vn", ":Notifications<CR>", "Notifications"),

  -- visual mode
  Key("v", "<", "<gv", "Indent Left"),
  Key("v", ">", ">gv", "Indent Right"),
  -- visual block mode
  Key("x", "J", ":move '>+1<CR>gv-gv", "Move Block Down"),
  Key("x", "K", ":move '>-2<CR>gv-gv", "Move Block Up"),
  Key("x", "<A-j>", ":move '>+1<CR>gv-gv", "Move Block Down"),
  Key("x", "<A-k>", ":move '>-2<CR>gv-gv", "Move Block Up"),
  -- term mode
  Key("t", "<C-h>", "<C-\\><C-N><C-w>h", "Navigate Left"),
  Key("t", "<C-j>", "<C-\\><C-N><C-w>j", "Navigate Down"),
  Key("t", "<C-k>", "<C-\\><C-N><C-w>k", "Navigate Up"),
  Key("t", "<C-l>", "<C-\\><C-N><C-w>l", "Navigate Right"),
  Key("t", "jk", "<C-\\><C-N>", "Normal Model"),
  Key("t", "<C-q>", "<cmd>bdelete!<CR>", "Force Quit Terminal"),
  -- command mode
  Key("c", "<C-j>", 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', "Select Next"):expr(),
  Key("c", "<C-k>", 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', "Select Previous"):expr(),
}

M.mac_keys = {
  Key("n", "<A-Up>", ":resize -2<CR>", "Resize Up"),
  Key("n", "<A-Down>", ":resize +2<CR>", "Resize Down"),
  Key("n", "<A-Left>", ":vertical resize -2<CR>", "Resize Left"),
  Key("n", "<A-Right>", ":vertical resize +2<CR>", "Resize Right"),
}

M.setup = function()
  M.load_keys(M.keys)
  if path.is_mac then
    M.load_keys(M.mac_keys)
    Log:debug("Activated mac keymappings")
  end
end

M.load = function(keymaps)
  keymaps = keymaps or {}
  for mode, mapping in pairs(keymaps) do
    local opts = { noremap = true, silent = true }
    for key, val in pairs(mapping) do
      if type(val) == "table" then
        opts = val[2]
        val = val[1]
      end
      vim.keymap.set(mode, key, val, opts)
      -- vim.api.nvim_set_keymap(mode, key, val, opts)
    end
  end
end

M.load_keys = function(keymaps)
  keymaps = keymaps or {}
  for _, key in ipairs(keymaps) do
    key:set()
  end
end

return M
