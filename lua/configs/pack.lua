vim.pack.add(
	{
		{ src = "https://github.com/folke/which-key.nvim" },
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
		{ src = "https://github.com/mfussenegger/nvim-dap" },
	}
)

vim.api.nvim_create_autocmd('VimEnter', {
	callback = function()
		vim.defer_fn(function()
			require('configs.whichkey').setup()
			require('configs.dap').setup()
			require("configs.treesitter").setup()
		end, 100)
	end,
})
