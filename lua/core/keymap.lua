local M = {}

M.setup = function()
  -- insert mode
  utils.Key("i", "<C-a>", "<Esc>ggVG", "Select All")
  utils.Key("i", "<C-s>", "<Esc><cmd>w<CR>", "Write")
  -- Key("i", "<C-z>", "<C-G>u<C-o>u", "Undo")
  utils.Key("i", "<C-u>", "<C-G>u<C-u>", "Delete Before")
  utils.Key("i", "<C-w>", "<C-G>u<C-w>", "Delete Word")
  -- Key("i", "<CR>", "<C-G>u<CR>", "CR")
  utils.Key("i", "jj", "<Esc>")
  utils.Key("i", "jk", "<Esc>")
  utils.Key("i", "kj", "<Esc>")
  utils.Key("i", "<A-j>", "<Esc>:m .+1<CR>==gi", "Move Line Down")
  utils.Key("i", "<A-k>", "<Esc>:m .-2<CR>==gi", "Move Line Up")
  utils.Key("i", "<A-Left>", "<C-\\><C-N><C-w>h", "Navigate Left")
  utils.Key("i", "<A-Down>", "<C-\\><C-N><C-w>j", "Navigate Down")
  utils.Key("i", "<A-Up>", "<C-\\><C-N><C-w>k", "Navigate Up")
  utils.Key("i", "<A-Right>", "<C-\\><C-N><C-w>l", "Navigate Right")

  -- normal mode
  utils.Key("n", "<C-a>", "ggVG", "Select All")
  utils.Key("n", "<C-s>", ":w<CR>", "Write")
  utils.Key("n", "<Esc>", ":noh<CR>", "No Highlight")
  utils.Key("n", "D", "d$")
  utils.Key("n", "Y", "y$")
  utils.Key("x", "p", [["_dP]])
  -- Key({ "n", "x" }, "p", [["0p]])
  -- Key({ "n", "x" }, "P", [["0P]])
  utils.Key({ "n", "x" }, "x", [["-x]])
  utils.Key({ "n", "x" }, "c", [["-c]])
  utils.Key({ "n", "x", "o" }, "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
  utils.Key({ "n", "x", "o" }, "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
  utils.Key({ "n", "x", "o" }, "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
  utils.Key({ "n", "x", "o" }, "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
  utils.Key("n", "gj", "j")
  utils.Key("n", "gk", "k")
  utils.Key("n", "<C-h>", "<C-w>h", "Navigate Left")
  utils.Key("n", "<C-j>", "<C-w>j", "Navigate Down")
  utils.Key("n", "<C-k>", "<C-w>k", "Navigate Up")
  utils.Key("n", "<C-l>", "<C-w>l", "Navigate Right")
  utils.Key("n", "<C-Up>", ":resize -2<CR>", "Resize Up")
  utils.Key("n", "<C-Down>", ":resize +2<CR>", "Resize Down")
  utils.Key("n", "<C-Left>", ":vertical resize -2<CR>", "Resize Left")
  utils.Key("n", "<C-Right>", ":vertical resize +2<CR>", "Resize Right")
  utils.Key("n", "<A-j>", ":m .+1<CR>==", "Move Line Down")
  utils.Key("n", "<A-k>", ":m .-2<CR>==", "Move Line Up")

  utils.IKey("n", "<F2>", [[yiw:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>]], "Substitute CurWord"):nosilent():set()
  utils.IKey("v", "<F2>", [[y:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>]], "Substitute CurWord"):nosilent():set()
  utils.Key("n", "<F3>", "yiw", "Yank CurWord")
  utils.Key("n", "<F4>", 'viw"_dP', "Paste CurWord")

  utils.Key("n", "<Leader>=", "<C-w>=", "Resize Windows")
  utils.Key("n", "<Leader>q", ":q!<CR>", "Force Quit")
  utils.Key("n", "<Leader>Q", ":wqa<CR>", "Quit")
  utils.Key("n", "<Leader>up", wrap(require("utils.startup").setup, { print = true }), "Startup Time")
  utils.Key("n", "<Leader>uh", ":checkhealth<CR>", "Check Health")
  utils.Key("n", "<Leader>uH", ":checktime<CR>", "Check Time")
  utils.Key("n", "<Leader>um", ":messages<CR>", "Messages")
  utils.Key("n", "<Leader>un", ":Notifications<CR>", "Notifications")
  utils.Key("n", "<Leader>uM", wrap(require("utils.buffer").output_in_buffer, "messages"), "Messages Buffer")
  utils.Key("n", "<Leader>uN", wrap(require("utils.buffer").output_in_buffer, "Notifications"), "Notifications Buffer")

  -- visual mode
  utils.Key("v", "<", "<gv", "Indent Left")
  utils.Key("v", ">", ">gv", "Indent Right")

  -- visual block mode
  utils.Key("x", "J", ":move '>+1<CR>gv-gv", "Move Block Down")
  utils.Key("x", "K", ":move '>-2<CR>gv-gv", "Move Block Up")
  utils.Key("x", "<A-j>", ":move '>+1<CR>gv-gv", "Move Block Down")
  utils.Key("x", "<A-k>", ":move '>-2<CR>gv-gv", "Move Block Up")

  -- term mode
  utils.Key("t", "<C-h>", "<C-\\><C-N><C-w>h", "Navigate Left")
  utils.Key("t", "<C-j>", "<C-\\><C-N><C-w>j", "Navigate Down")
  utils.Key("t", "<C-k>", "<C-\\><C-N><C-w>k", "Navigate Up")
  utils.Key("t", "<C-l>", "<C-\\><C-N><C-w>l", "Navigate Right")
  utils.Key("t", "jk", "<C-\\><C-N>", "Normal Model")
  utils.Key("t", "<C-q>", "<cmd>bdelete!<CR>", "Force Quit Terminal")

  -- command mode
  utils.IKey("c", "<C-j>", 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', "Select Next"):expr():set()
  utils.IKey("c", "<C-k>", 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', "Select Previous"):expr():set()

  -- toggle
  utils.Key("n", "[os", "<cmd>setlocal spell<CR>", "Spell")
  utils.Key("n", "]os", "<cmd>setlocal nospell<CR>", "Spell")
  utils.Key("n", "yos", "<cmd>setlocal invspell<CR>", "Spell")

  utils.Key("n", "[ow", "<cmd>setlocal wrap<CR>", "Wrap")
  utils.Key("n", "]ow", "<cmd>setlocal nowrap<CR>", "Wrap")
  utils.Key("n", "yow", "<cmd>setlocal invwrap<CR>", "Wrap")

  utils.Key("n", "[om", "<cmd>setlocal modifiable<CR>", "Modifiable")
  utils.Key("n", "]om", "<cmd>setlocal nomodifiable<CR>", "Modifiable")
  utils.Key("n", "yom", "<cmd>setlocal invmodifiable<CR>", "Modifiable")

  utils.Key("n", "[oM", "<cmd>set mouse=a<CR>", "Mouse")
  utils.Key("n", "]oM", "<cmd>set mouse=<CR>", "Mouse")
  utils.Key("n", "yoM", function()
    if vim.api.nvim_get_option("mouse") == "a" then
      vim.api.nvim_set_option("mouse", "")
    else
      vim.api.nvim_set_option("mouse", "a")
    end
  end, "Mouse")

  utils.Key("n", "[on", "<cmd>setlocal number<CR>", "Number")
  utils.Key("n", "]on", "<cmd>setlocal nonumber<CR>", "Number")
  utils.Key("n", "yon", "<cmd>setlocal invnumber<CR>", "Number")

  utils.Key("n", "[or", "<cmd>setlocal relativenumber<CR>", "Relative Number")
  utils.Key("n", "]or", "<cmd>setlocal norelativenumber<CR>", "Relative Number")
  utils.Key("n", "yor", "<cmd>setlocal invrelativenumber<CR>", "Relative Number")

  utils.Key("n", "[q", "<cmd>cprevious<CR>", "Previous Quickfix")
  utils.Key("n", "]q", "<cmd>cnext<CR>", "Next Quickfix")

  utils.Key("n", "[<Space>", "<cmd>put!=repeat(nr2char(10), v:count1)|silent<CR>", "Previous Add Lines")
  utils.Key("n", "]<Space>", "<cmd>put =repeat(nr2char(10), v:count1)|silent<CR>", "Previous Add Lines")

  -- Which-Key Groups
  utils.load({
    utils.IKey("n", "<Leader>"):group("Leader"),
    utils.IKey("n", "["):group("Previous Move"),
    utils.IKey("n", "]"):group("Next Move"),
    utils.IKey("n", "g"):group("Goto"),
    utils.IKey("n", "z"):group("Fold"),
    utils.IKey("n", "<Leader>t"):group("Terminal"),
    utils.IKey("n", "<Leader>m"):group("Module"),
    utils.IKey("n", "<Leader>u"):group("Utils"),

    utils.IKey("n", "<C-y>"):desc("Scroll UP Little"),
    utils.IKey("n", "<C-u>"):desc("Scroll UP Much"),
    utils.IKey("n", "<C-b>"):desc("Scroll UP Page"),
    utils.IKey("n", "<C-e>"):desc("Scroll Down Little"),
    utils.IKey("n", "<C-d>"):desc("Scroll Down Much"),
    utils.IKey("n", "<C-f>"):desc("Scroll Down Page"),
    utils.IKey("n", "<C-\\>"):desc("Terminal"),

    -- option toggle
    utils.IKey("n", "[o"):group("Toggle ON"),
    utils.IKey("n", "]o"):group("Toggle OFF"),
    utils.IKey("n", "yo"):group("Toggle"),
  })
end

return M
