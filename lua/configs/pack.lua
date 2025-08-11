local plugins = {
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
}

vim.pack.add(plugins)

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
	callback = function()
		require("configs.treesitter")
	end,
})

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim.defer_fn(function()
			require('configs.whichkey')
		end, 100) -- load after 100ms
	end,
})
