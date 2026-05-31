-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-----------------------------------------------------------
-- General
-----------------------------------------------------------
vim.o.mouse = 'a' -- Enable mouse support
vim.o.relativenumber = true -- set relative numbered lines
vim.o.showmode = false -- don't show the mode, since its already in status line
vim.o.clipboard = 'unnamedplus' -- Copy/paste to system clipboard
vim.o.breakindent = true -- Enable break indent
vim.o.swapfile = false -- Don't use swapfile
vim.o.undofile = true -- enable persistent undo
vim.o.completeopt = 'menuone,noselect,noinsert'

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Make line numbers default
vim.wo.number = true
vim.o.showmatch = true -- Highlight matching parenthesis
vim.o.foldmethod = 'marker' -- Enable folding (default 'foldmarker')
vim.o.colorcolumn = '79' -- Line length marker at 80 columns
vim.o.splitright = true -- Vertical split to the right
vim.o.splitbelow = true -- Horizontal split to the bottom

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.linebreak = true -- Wrap on word boundary
vim.o.laststatus = 3 -- Set global statusline

vim.o.guifont = 'monospace:h17' -- the font used in graphical neovim applications
vim.o.cmdheight = 2 -- more space in the neovim command line for displaying messages
vim.o.cursorline = true -- highlight the current line
vim.o.spelllang = 'en_us' -- Set the spell language to en
vim.o.spell = true -- Enable spell checking

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-----------------------------------------------------------
-- Tabs, indent and others
-----------------------------------------------------------
vim.o.textwidth = 79
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.shiftwidth = 4 -- Shift 4 spaces when tab
vim.o.shiftround = true
vim.o.tabstop = 4 -- 1 tab == 4 spaces
vim.o.smartindent = true -- Autoindent new lines
vim.o.softtabstop = 4 -- Tab character that is 4 columns wide.
vim.o.autoindent = true

vim.o.numberwidth = 4 -- set number column width to 4 {default 4}
vim.o.signcolumn = 'yes' -- always show the sign column, otherwise it would shift the text each time
vim.o.wrap = false -- display lines as one long line
vim.o.scrolloff = 10 -- Always 8 lines while moving up/down
vim.o.sidescrolloff = 8
vim.o.autowrite = true -- Automatically write buffer before running certain commands, including running Lua code
vim.o.infercase = false

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
vim.o.timeoutlen = 300
vim.o.hidden = true -- Enable background buffers
vim.o.history = 100 -- Remember N lines in history
vim.o.lazyredraw = true -- Faster scrolling
vim.o.synmaxcol = 240 -- Max column for syntax highlight
vim.o.updatetime = 250 -- ms to wait for trigger an event

-----------------------------------------------------------
-- Others
-----------------------------------------------------------

vim.o.backup = false -- creates a backup file
vim.o.conceallevel = 2 -- so that `` is visible in markdown files
vim.o.fileencoding = 'utf-8' -- the encoding written to a file
vim.o.hlsearch = false -- highlight all matches on previous search pattern
vim.o.incsearch = true
vim.o.pumheight = 10 -- pop up menu height
vim.o.timeoutlen = 1000 -- time to wait for a mapped sequence to complete (in milliseconds)
vim.o.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vim.o.undodir = os.getenv 'HOME' .. '/.vim/undodir'

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-----------------------------------------------------------
-- NVIM PYTHON location
-- vim.g.python3_host_prog = '/usr/local/bin/python3'
-- reference: https://github.com/CharlesChiuGit/nvimdots.lua/blob/main/lua/core/options.lua
-----------------------------------------------------------
local function isempty(s)
  return s == nil or s == ''
end
local function use_if_defined(val, fallback)
  return val ~= nil and val or fallback
end

-- custom python provider
local conda_prefix = os.getenv 'CONDA_PREFIX'
if not isempty(conda_prefix) then
  vim.g.python_host_prog = use_if_defined(vim.g.python_host_prog, conda_prefix .. '/bin/python')
  vim.g.python3_host_prog = use_if_defined(vim.g.python3_host_prog, conda_prefix .. '/bin/python3')
else
  vim.g.python_host_prog = use_if_defined(vim.g.python_host_prog, '/Users/fcp/mambaforge/bin/python')
  vim.g.python3_host_prog = use_if_defined(vim.g.python3_host_prog, '/Users/fcp/mambaforge/bin/python3')
end
-----------------------------------------------------------
