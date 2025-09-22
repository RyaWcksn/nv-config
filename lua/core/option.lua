vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.o.undofile = true
vim.o.pumheight = 10
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.hlsearch = false
vim.o.termguicolors = true

vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.path = '.,,**'
vim.opt.clipboard = "unnamed"
vim.opt.clipboard:append { "unnamedplus" }
vim.opt.completeopt = { "menuone", "noselect", 'fuzzy', 'popup' }

-- Nicer grepping when `rg` is available.
if vim.fn.executable('rg') then
	vim.opt.grepprg = 'rg --vimgrep --no-heading'
	vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
end
