-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-----------------------------------------------------------
-- [[ My keymap]]
-----------------------------------------------------------
-- Disable the space bar in normal and visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Space + pv == Netrw
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = 'Netrw' })

-- When in (v)isual mode, you can press (J) or (K)
-- to (m)ove the list down/up
-- BONUS: if you have a if/end statements you can move up/down with the below
-- command. the program will automatically indent the code!!!! INSANE GOOD
-- if true then
-- end
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv")
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv")

-- `Ctrl + d` and `Ctrl + u` are half page jumping + zz, the cursor  will
-- stay in the middle of the page.
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Allow us to search terms in the middle of the page.
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- This key mapping allows you to delete the currently selected text in visual
-- mode without affecting the unnamed clipboard and then paste the previously
-- yanked text in place of what you just deleted. It's a very handy way to
-- replace a section of text with something you've copied earlier.
-- First, yank some text you want to paste later by selecting it (with v for
-- visual mode or V for visual line mode) and pressing y. Navigate to another
-- section of text you want to replace. Enter visual mode again (v or V) and
-- select the text you want to replace. Press <leader>p (which might be Space+p
-- if your leader is the spacebar). The selected text will be deleted without
-- affecting the clipboard, and the text you yanked in step 1 will be pasted in
-- its place.
vim.keymap.set('x', '<leader>p', [["_dP]])

-- `Space + s` will , the overall effect of this code is to remap the n key in
-- normal mode to perform a global search and replace operation, using the
-- contents of the clipboard as both the search and replacement patterns,
-- and then move the cursor to the left to allow you to start typing immediately
-- after the replace operation.
-- vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
