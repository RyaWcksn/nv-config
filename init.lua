require('core')
require('configs')

if vim.loader then vim.loader.enable() end

vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		-- vim.cmd.colorscheme("ayu")
		-- vim.cmd.colorscheme("neko")
		vim.cmd.colorscheme("miku-vibrant")
		-- vim.cmd.colorscheme("grayscale")
		-- vim.cmd.colorscheme("eink")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		pcall(vim.treesitter.start)
	end
})
