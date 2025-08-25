local augroup = vim.api.nvim_create_augroup('user_cmds', { clear = true })

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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "notesfloat" },
	callback = function()
		vim.cmd("LspStop")
		vim.opt_local.winbar = nil
		vim.opt_local.laststatus = 0
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.completefunc = ""
		vim.opt_local.omnifunc = ""
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "todo.md",
	callback = function()
		local utils = require('utils.utils')
		utils.move_done_items()
	end
})

vim.api.nvim_create_autocmd("InsertLeave", {
	pattern = "*",
	callback = function()
		-- Only save if buffer is modifiable and changed
		if vim.bo.modifiable and vim.bo.modified then
			vim.cmd("silent write")
		end
	end,
})

-- Define custom highlight groups for heading levels
vim.api.nvim_set_hl(0, "MarkdownH1", { bold = true, fg = "#FFD700" }) -- gold, biggest
vim.api.nvim_set_hl(0, "MarkdownH2", { bold = true, fg = "#87CEFA" }) -- sky blue
vim.api.nvim_set_hl(0, "MarkdownH3", { bold = true, fg = "#ADFF2F" }) -- green
vim.api.nvim_set_hl(0, "MarkdownH4", { bold = true, fg = "#FF69B4" }) -- pink

-- Create autocmd for markdown
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		-- Clear default heading matches if needed
		vim.cmd [[syntax clear markdownH1 markdownH2 markdownH3 markdownH4]]

		-- Match ATX-style headings (#, ##, ###, ####)
		vim.cmd [[syntax match MarkdownH1 /^# .*/]]
		vim.cmd [[syntax match MarkdownH2 /^## .*/]]
		vim.cmd [[syntax match MarkdownH3 /^### .*/]]
		vim.cmd [[syntax match MarkdownH4 /^#### .*/]]

		-- Link them to custom highlight groups
		vim.cmd [[highlight link MarkdownH1 MarkdownH1]]
		vim.cmd [[highlight link MarkdownH2 MarkdownH2]]
		vim.cmd [[highlight link MarkdownH3 MarkdownH3]]
		vim.cmd [[highlight link MarkdownH4 MarkdownH4]]
	end,
})
