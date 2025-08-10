require('core')
require('configs')

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim.cmd.colorscheme("ayu")
	end,
})
