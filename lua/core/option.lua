vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.o.undofile = true
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.termguicolors = true

vim.g.mapleader = " "

vim.opt.termguicolors = true
vim.opt.path:append(",,**")
vim.opt.clipboard:append("unnamedplus")
vim.opt.completeopt = { "menuone", "noselect", 'fuzzy', 'popup' }

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true


-- Nicer grepping when `rg` is available.
if vim.fn.executable('rg') then
	vim.o.grepprg = table.concat({
		'rg',
		'--vimgrep',
		'--no-heading',
		'--smart-case',
		'-g "!*openapi*.json"',
		'-g "!*swagger*.json"',
		'-g "!*openapi*.yaml"',
		'-g "!*swagger*.yaml"',
		'-g "!build/"',
		'-g "!target/"',
		'-g "!dist/"',
	}, ' ')
	vim.o.grepformat = '%f:%l:%c:%m'
end
