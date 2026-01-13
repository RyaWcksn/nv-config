if vim.fn.executable('sudo') then
	vim.api.nvim_create_user_command('W', 'silent! write !sudo tee % >/dev/null', {
		force = true,
	})
end

vim.api.nvim_create_user_command(
	'Search',
	function(opts)
		vim.cmd('silent grep! ' .. opts.args)
		vim.cmd('copen')
	end,
	{
		nargs = '+',
		desc = 'Find in project (using rg) and open quickfix list',
	}
)
