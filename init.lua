require('core')
require('configs')

local tracker = require('utils.tracker')

local filter = {
	"sql",
}

local db_path = "~/log_tracker.db"

tracker.setup({
	db_path = db_path,
	filter = filter,
})

if vim.loader then vim.loader.enable() end

vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		vim.cmd.colorscheme("miku-vibrant")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		pcall(vim.treesitter.start)
	end
})
