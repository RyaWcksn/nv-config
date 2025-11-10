local augroup = vim.api.nvim_create_augroup('user_cmds', { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end
})

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'help', 'man', 'qf', 'notesfloat', 'findfile' },
	group = augroup,
	desc = 'Use q to close the window',
	command = 'nnoremap <buffer> q <cmd>quit<cr>'
})

vim.api.nvim_create_autocmd('TextYankPost', {
	group = augroup,
	callback = function()
		vim.highlight.on_yank({ higroup = 'Visual', timeout = 200 })
	end,
	desc = "Add highlight on yank text"
})


vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.md",
	callback = function()
		local prettier_cmd = "prettier --parser markdown"
		local handle = io.popen(prettier_cmd .. " 2>/dev/null")
		if handle and handle:read("*a") ~= "" then
			vim.cmd("%!prettier --parser markdown")
		end
	end,
	desc = "Pretty print markdown file"
})

vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*.csv",

	callback = function()
		if vim.bo.buftype ~= "" then return end

		vim.wo.wrap = false
		vim.bo.filetype = "csv"

		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

		local split = function(str, sep)
			local result = {}
			for s in string.gmatch(str, "([^" .. sep .. "]+)") do
				table.insert(result, s)
			end
			return result
		end

		local columns = {}
		local parsed = {}

		for _, line in ipairs(lines) do
			local fields = split(line, ",")
			for i, field in ipairs(fields) do
				columns[i] = math.max(columns[i] or 0, #field)
			end
			table.insert(parsed, fields)
		end

		local formatted = {}
		for _, row in ipairs(parsed) do
			local new_line = {}
			for i, cell in ipairs(row) do
				table.insert(new_line, string.format("%-" .. columns[i] .. "s", cell))
			end
			table.insert(formatted, table.concat(new_line, " | "))
		end

		vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
		vim.bo.modified = false -- Don't mark buffer as modified
	end,
	desc = "Pretty print CSV"
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "todo.md",
	callback = function()
		local utils = require('utils.utils')
		utils.move_done_items()
	end
})
