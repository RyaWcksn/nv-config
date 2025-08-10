local plugins = {
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
}

vim.pack.add(plugins)

vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function()
		require("configs.treesitter")
	end,
})

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.defer_fn(function()
			require("configs.whichkey")
		end, 50)
	end,
})
