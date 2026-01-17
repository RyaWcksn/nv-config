vim.pack.add(
	{
		{ src = "https://github.com/folke/which-key.nvim" },
		{ src = "https://github.com/mfussenegger/nvim-dap" },
	}
)

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim.defer_fn(function()
			require('configs.whichkey').setup()
			require('configs.dap').setup()
		end, 100)
	end,
})
