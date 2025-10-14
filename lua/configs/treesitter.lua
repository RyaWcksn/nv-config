M = {}

M.setup = function()
	local config = require("nvim-treesitter.config")
	config.setup({
		ensure_installed = {
			"go",
			"javascript",
			"typescript",
			"lua",
			"tsx",
			"rust",
			"python",
			"templ",
		},
		indent = {
			enable = true,
		},
		highlight = {
			enable = true,
			disable = function(_, buf)
				local max_filesize = 50 * 1024
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
		},
		auto_install = true,
	})
end

return M
