local M = {}
local Key = utils.Key

M.keys = {
  -- insert mode
  Key("i", "<C-a>", "<Esc>ggVG", "Select All"),
  Key("i", "<C-s>", "<Esc><cmd>w<CR>", "Write"),
  -- Key("i", "<C-z>", "<C-G>u<C-o>u", "Undo"),
  Key("i", "<C-u>", "<C-G>u<C-u>", "Delete Before"),
  Key("i", "<C-w>", "<C-G>u<C-w>", "Delete Word"),
  -- Key("i", "<CR>", "<C-G>u<CR>", "CR"),
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
  Key("x", "p", [["-dP]]),
  -- Key({ "n", "x" }, "p", [["0p]]),
  -- Key({ "n", "x" }, "P", [["0P]]),
  Key({ "n", "x" }, "x", [["-x]]),
  Key({ "n", "x" }, "c", [["-c]]),
  -- Key({ "n", "x" }, "<Leader>y", [["+]]),
  Key({ "n", "x", "o" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"'):expr(),
  Key({ "n", "x", "o" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"'):expr(),
  Key("", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"'):expr(),
  Key("", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"'):expr(),
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

  Key("n", "<F2>", [[yiw:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>]], "Substitute CurWord"):nosilent(),
  Key("v", "<F2>", [[y:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>]], "Substitute CurWord"):nosilent(),
  Key("n", "<F3>", "yiw", "Yank CurWord"),
  Key("n", "<F4>", 'viw"-dP', "Paste CurWord"),

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
  -- Key("n", "<Leader>w", ":w!<CR>", "Save"),
  Key("n", "<Leader>q", ":q!<CR>", "Force Quit"),
  Key("n", "<Leader>Q", ":wqa<CR>", "Quit"),
  -- Key("n", "<Leader>h", ":nohlsearch<CR>", "No Highlight"),
  Key("n", "<Leader>t"):group("Terminal"),
  Key("n", "<Leader>m"):group("Module"),
  Key("n", "<Leader>u"):group("Utils"),
  Key("n", "<Leader>up", wrap(require("utils.startup").setup, { print = true }), "Startup Time"),
  Key("n", "<Leader>uh", ":checkhealth<CR>", "Check Health"),
  Key("n", "<Leader>uH", ":checktime<CR>", "Check Time"),
  Key("n", "<Leader>um", ":messages<CR>", "Messages"),
  Key("n", "<Leader>un", ":Notifications<CR>", "Notifications"),
  Key("n", "<Leader>uM", wrap(require("utils.buffer").output_in_buffer, "messages"), "Messages Buffer"),
  Key("n", "<Leader>uN", wrap(require("utils.buffer").output_in_buffer, "Notifications"), "Notifications Buffer"),

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

  -- option toggle
  Key("n", "[o"):group("Toggle ON"),
  Key("n", "]o"):group("Toggle OFF"),
  Key("n", "yo"):group("Toggle"),

  Key("n", "[os", "<cmd>setlocal spell<CR>", "Spell"),
  Key("n", "]os", "<cmd>setlocal nospell<CR>", "Spell"),
  Key("n", "yos", "<cmd>setlocal invspell<CR>", "Spell"),

  Key("n", "[ow", "<cmd>setlocal wrap<CR>", "Wrap"),
  Key("n", "]ow", "<cmd>setlocal nowrap<CR>", "Wrap"),
  Key("n", "yow", "<cmd>setlocal invwrap<CR>", "Wrap"),

  Key("n", "[om", "<cmd>setlocal modifiable<CR>", "Modifiable"),
  Key("n", "]om", "<cmd>setlocal nomodifiable<CR>", "Modifiable"),
  Key("n", "yom", "<cmd>setlocal invmodifiable<CR>", "Modifiable"),

  Key("n", "[oM", "<cmd>set mouse=a<CR>", "Mouse"),
  Key("n", "]oM", "<cmd>set mouse=<CR>", "Mouse"),
  Key("n", "yoM", function()
    if vim.api.nvim_get_option("mouse") == "a" then
      vim.api.nvim_set_option("mouse", "")
    else
      vim.api.nvim_set_option("mouse", "a")
    end
  end, "Mouse"),

  Key("n", "[on", "<cmd>setlocal number<CR>", "Number"),
  Key("n", "]on", "<cmd>setlocal nonumber<CR>", "Number"),
  Key("n", "yon", "<cmd>setlocal invnumber<CR>", "Number"),

  Key("n", "[or", "<cmd>setlocal relativenumber<CR>", "Relative Number"),
  Key("n", "]or", "<cmd>setlocal norelativenumber<CR>", "Relative Number"),
  Key("n", "yor", "<cmd>setlocal invrelativenumber<CR>", "Relative Number"),

  Key("n", "[q", "<cmd>cprevious<CR>", "Previous Quickfix"),
  Key("n", "]q", "<cmd>cnext<CR>", "Next Quickfix"),

  Key("n", "[<Space>", "<cmd>put!=repeat(nr2char(10), v:count1)|silent<CR>", "Previous Add Lines"),
  Key("n", "]<Space>", "<cmd>put =repeat(nr2char(10), v:count1)|silent<CR>", "Previous Add Lines"),
}

M.setup = function()
  for _, key in ipairs(M.keys) do
    key:set()
  end
end

return M
