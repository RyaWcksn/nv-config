vim.pack.add(
	{
		{ src = "https://github.com/folke/which-key.nvim" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
		{ src = "https://github.com/mfussenegger/nvim-dap" },
	}
)

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
	callback = function()
		require("configs.treesitter")
	end,
})

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim.defer_fn(function()
			require('configs.whichkey')
			require('configs.dap').setup()
		end, 100)
	end,
})
