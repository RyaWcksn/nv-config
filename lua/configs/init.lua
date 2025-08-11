vim.api.nvim_create_autocmd({ 'BufRead', 'BufReadPre', 'BufEnter' }, {
	callback = function()
		require('configs.pack')
		require("configs.lsp")
	end
})
