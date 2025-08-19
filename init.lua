require('core')
require('configs')

if vim.loader then vim.loader.enable() end

vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		-- vim.cmd.colorscheme("ayu")
		vim.cmd.colorscheme("neko")
	end,
})
