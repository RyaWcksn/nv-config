vim.api.nvim_create_autocmd({ 'VimEnter', 'BufReadPre', 'BufNewFile' }, {
	callback = function()
		require('core.netrw')
		require('core.option')
		require('core.mapping')
		require('core.statusline')
		require('core.fold')
		require('core.autocmd')
		require('core.commands')
	end,
})

local disabled_built_ins = {
	"gzip", "zip", "zipPlugin", "tar", "tarPlugin", "getscript", "getscriptPlugin",
	"vimball", "vimballPlugin", "2html_plugin", "matchit", "matchparen", "logipat", "rrhelper"
}
for _, plugin in pairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end
