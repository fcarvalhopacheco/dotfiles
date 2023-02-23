-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
-- Space == <leader>

vim.g.mapleader = " "

-- Space + pv == Netrw 
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Normal --
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h",{desc = '<C-h> move to left window'})
vim.keymap.set("n", "<C-j>", "<C-w>j",{desc = '<C-j> move to bottom window'})
vim.keymap.set("n", "<C-k>", "<C-w>k",{desc = '<C-k> move to upper window'})
vim.keymap.set("n", "<C-l>", "<C-w>l",{desc = '<C-l> move to right window'})

-- When in (v)isual mode, you can press (J) or (K)
-- to (m)ove the list down/up 
-- BONUS: if you have a if/end statementm you can move up/down with the below
-- command. the program will automatically indent the code!!!! INSANE GOOD
-- test it!!!
-- if true then
--
-- end
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- (J) gets the line below and appends to the current line with space. However
-- the cursor moves to the end of the line. With the remap below, your cursor
-- will remain in the same place
vim.keymap.set("n", "J", "mzJ`z")


-- `Ctrl + d` and `Ctrl + u` are half page jumping + zz, the cursor  will
-- stay in the middle of the page.
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")


-- Allow us to search terms in the middle of the page.
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Ex: You highlight and copy a word. Then you highlight another word
-- and you paste the old word over the new word. You will loose the yank from 
-- the "old" word if you. The following remap <leader>p will delete the new 
-- higlighted word into the void register and then paste it over
-- In summary: the old(first) word will be always preserved...
vim.keymap.set("x", "<leader>p", [["_dP]])


-- <Space + y> will be "+y   --> This is the +register (system clipboard).
-- It is like yanking line(s) and saving/registering it(they) into the register
-- + 
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- "Black hole register" == "_   
-- The "_d" command will deleteyping "_d will delete under the cursor without 
-- changing the unnamed register.
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])


-- `Space + s` will , the overall effect of this code is to remap the n key in 
-- normal mode to perform a global search and replace operation, using the 
-- contents of the clipboard as both the search and replacement patterns, 
-- and then move the cursor to the left to allow you to start typing immediately 
-- after the replace operation.

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])


