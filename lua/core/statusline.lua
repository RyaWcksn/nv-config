local function mode()
	return ' 有 '
end

local function filepath()
	local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
	if fpath == "" or fpath == "." then
		return " "
	end

	return string.format(" %%<%s/", fpath)
end

local function filename()
	local fname = vim.fn.expand "%:t"
	if fname == "" then
		return ""
	end
	if vim.api.nvim_get_option_value('modified', { buf = 0 }) == 1 then
		fname = fname .. "*"
	end
	return fname .. " "
end


local function lsp()
	local count = {}
	local levels = {
		errors = vim.diagnostic.severity.ERROR,
		warnings = vim.diagnostic.severity.WARN,
		info = vim.diagnostic.severity.INFO,
		hints = vim.diagnostic.severity.HINT,
	}

	for k, level in pairs(levels) do
		count[k] = vim.tbl_count(vim.diagnostic.get(0, { severity = level }))
	end

	local errors = ""
	local warnings = ""
	local hints = ""
	local info = ""

	if count["errors"] ~= 0 then
		errors = " %#Normal#ERR [" .. count["errors"] .. "]"
	end
	if count["warnings"] ~= 0 then
		warnings = " %#Normal#WARN [" .. count["warnings"] .. "]"
	end
	if count["hints"] ~= 0 then
		hints = " %#Normal#HINT [" .. count["hints"] .. "]"
	end
	if count["info"] ~= 0 then
		info = " %#Normal#INFO [" .. count["info"] .. "]"
	end


	return errors .. warnings .. hints .. info .. "%#Normal# "
end

local function lsp_servers()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if not clients or #clients == 0 then
		return 'No Active Lsp'
	end
	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	return string.format(" LSP [ %s ]", table.concat(names, ', '))
end

local function get_git_branch()
	local handle = io.popen('git rev-parse --abbrev-ref HEAD 2>/dev/null')
	local result = handle:read('*l')
	handle:close()
	result = string.format(" [%s] ", result)
	return result or '!git'
end

local function get_project_name()
	-- Get the current working directory (CWD)
	local cwd = vim.fn.getcwd()
	-- Extract the last part of the path (the project name)
	return vim.fn.fnamemodify(cwd, ":t")
end

local function statusbar_exec(ev)
	local statusline = {
		"%#Normal#",
		mode(),
		get_git_branch(),
		filepath() .. filename() .. "%r",
		"%=%#Extra#",
		"%#Normal#",
		lsp_servers(),
		lsp(),
		get_project_name(),
	}
	vim.o.statusline = table.concat(statusline, '')
end

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "VimEnter", "BufWinEnter", "LspAttach" }, {
	callback = function(ev)
		statusbar_exec(ev)
	end
})


local statusline_filetype_exclude = {
	"help",
	"toggleterm",
	"AvanteInput",
	"Avante",
	"AvanteSelectedFiles",
	"qf",
	"prompt",
}

local function hide_statusline_in_netrw()
	if vim.tbl_contains(statusline_filetype_exclude, vim.bo.filetype) then
		vim.opt.laststatus = 0
		return
	end
	vim.opt.laststatus = 2 -- Show statusline for other buffers
end

-- Auto command to toggle statusline dynamically
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = hide_statusline_in_netrw,
})
