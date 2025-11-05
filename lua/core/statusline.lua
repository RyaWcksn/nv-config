Statusline = {}

local function mode()
	return '%#Normal# 有 '
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
		errors = " E [" .. count["errors"] .. "]"
	end
	if count["warnings"] ~= 0 then
		warnings = " W [" .. count["warnings"] .. "]"
	end
	if count["hints"] ~= 0 then
		hints = " H [" .. count["hints"] .. "]"
	end
	if count["info"] ~= 0 then
		info = " I [" .. count["info"] .. "]"
	end


	return errors .. warnings .. hints .. info .. "%#Normal# "
end

local function lsp_servers()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if not clients or #clients == 0 then
		return 'No Active Lsp'
	end
	return "[LSP]"
end

local function git_branch()
	local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
	if branch ~= "" then
		local result = string.format(" [%s] ", branch)
		return result
	end
	return ""
end

local function filepath()
	local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")

	if fpath == "" or fpath == "." then
		return ""
	end

	return string.format("%%<%s/", fpath)
end

function Statusline.active()
	return table.concat {
		mode(),
		"[", filepath(), "%t] ",
		lsp_servers(),
		lsp(),
		"%=",
		git_branch(),
	}
end

function Statusline.inactive()
	return " %t"
end

local function setup_statusline()
	local group = vim.api.nvim_create_augroup("Statusline", { clear = true })

	vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
		group = group,
		desc = "Activate statusline on focus",
		callback = function()
			vim.opt_local.statusline = "%!v:lua.Statusline.active()"
		end,
	})

	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		group = group,
		desc = "Deactivate statusline when unfocused",
		callback = function()
			vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
		end,
	})
end

setup_statusline()

local statusline_filetype_exclude = {
	"help",
	"toggleterm",
	"AvanteInput",
	"Avante",
	"AvanteSelectedFiles",
	"qf",
	"prompt",
	"netrw"
}

local function hide_statusline_in_netrw()
	if vim.tbl_contains(statusline_filetype_exclude, vim.bo.filetype) then
		vim.opt_local.laststatus = 0
		return
	end
	vim.opt_local.laststatus = 2 -- Show statusline for other buffers
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = hide_statusline_in_netrw,
})
