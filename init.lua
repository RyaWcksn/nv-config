require('core')
require('configs')

if vim.loader then vim.loader.enable() end

vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		vim.cmd.colorscheme("miku-vibrant")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		pcall(vim.treesitter.start)
	end
})
