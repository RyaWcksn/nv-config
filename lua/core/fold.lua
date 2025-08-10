function _G.myfolds()
	local line = vim.fn.getline(vim.v.foldstart)
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	return line .. " --------- " .. line_count .. " lines "
end

-- Fold
local vim = vim
local api = vim.api
local M = {}
-- function to create a list of commands and convert them to autocommands
-------- This function is taken from https://github.com/norcalli/nvim_utils
function M.nvim_create_augroups(definitions)
	for group_name, definition in pairs(definitions) do
		api.nvim_command('augroup ' .. group_name)
		api.nvim_command('autocmd!')
		for _, def in ipairs(definition) do
			local command = table.concat(
				vim.iter({ 'autocmd', def }):flatten():totable(),
				' '
			)
			api.nvim_command(command)
		end
		api.nvim_command('augroup END')
	end
end

local autoCommands = {
	open_folds = {
		{ "BufReadPost,FileReadPost", "*", "normal zR" }
	}
}

M.nvim_create_augroups(autoCommands)
