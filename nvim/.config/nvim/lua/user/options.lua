-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*

local g = vim.g -- Global variables
local opt = vim.opt -- Set options (global/buffer/windows-scoped)

-----------------------------------------------------------
-- General
-----------------------------------------------------------
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Copy/paste to system clipboard
opt.swapfile = false -- Don't use swapfile
opt.completeopt = { "menuone,noinsert,noselect" } -- Autocomplete options
-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
opt.number = true -- Show line number
opt.showmatch = true -- Highlight matching parenthesis

opt.foldmethod = "marker" -- Enable folding (default 'foldmarker')
opt.colorcolumn = "79" -- Line length marker at 80 columns
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom
opt.ignorecase = true -- Ignore case letters when search
opt.smartcase = true -- Ignore lowercase for the whole pattern
opt.linebreak = true -- Wrap on word boundary
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.laststatus = 3 -- Set global statusline
opt.guifont = "monospace:h17" -- the font used in graphical neovim applications
opt.cmdheight = 2 -- more space in the neovim command line for displaying messages
opt.cursorline = true -- highlight the current line
opt.relativenumber = true -- set relative numbered lines

-----------------------------------------------------------
-- Tabs, indent and others
-----------------------------------------------------------
opt.textwidth = 79
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 4 -- Shift 4 spaces when tab
opt.shiftround = true
opt.tabstop = 4 -- 1 tab == 4 spaces
opt.smartindent = true -- Autoindent new lines
opt.softtabstop = 4 -- Tab character that is 4 columns wide.
opt.autoindent = true

opt.numberwidth = 4 -- set number column width to 4 {default 4}
opt.signcolumn = "yes" -- always show the sign column, otherwise it would shift the text each time
opt.wrap = false -- display lines as one long line
opt.scrolloff = 8 -- Always 8 lines while moving up/down
opt.sidescrolloff = 8
opt.autowrite = true -- Automatically write buffer before running certain commands, including running Lua code
opt.infercase = false

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
opt.hidden = true -- Enable background buffers
opt.history = 100 -- Remember N lines in history
opt.lazyredraw = true -- Faster scrolling
opt.synmaxcol = 240 -- Max column for syntax highlight
opt.updatetime = 250 -- ms to wait for trigger an event

-----------------------------------------------------------
-- Others
-----------------------------------------------------------

opt.backup = false -- creates a backup file
opt.conceallevel = 0 -- so that `` is visible in markdown files
opt.fileencoding = "utf-8" -- the encoding written to a file
opt.hlsearch = false -- highlight all matches on previous search pattern
opt.incsearch = true
opt.pumheight = 10 -- pop up menu height
opt.timeoutlen = 1000 -- time to wait for a mapped sequence to complete (in milliseconds)
opt.undofile = true -- enable persistent undo
opt.writebackup = false -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"

g.mapleader = " "
opt.shortmess:append("c")
