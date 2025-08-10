require('configs.pack')
vim.api.nvim_create_autocmd({ 'BufRead', 'BufReadPre', 'BufEnter' }, {
	callback = function()
		require('configs.lsp')
	end
})
