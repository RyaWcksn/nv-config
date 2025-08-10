local winbar_filetype_exclude = {
	"help",
	"toggleterm",
	"netrw",
	"AvanteInput",
	"Avante",
	"AvanteSelectedFiles",
	"qf"
}


local excludes = function()
	if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
		vim.o.winbar = nil
		return true
	end
	return false
end

local winbar_exec = function()
	if excludes() then
		return
	end

	--- Format buffer list with highlight on current buffer
	---@return string
	local function format_buffer_list()
		local filenames = {}
		local current_buf = vim.api.nvim_get_current_buf()

		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf)
			    and vim.api.nvim_get_option_value('buftype', { buf = buf }) == ''
			    and vim.api.nvim_get_option_value('filetype', { buf = buf }) ~= 'netrw' then
				local name = vim.fn.bufname(buf)
				local filename = vim.fn.fnamemodify(name, ':t')

				-- Highlight the currently open buffer
				if buf == current_buf then
					table.insert(filenames, "%#IncSearch#" .. filename .. "%#Normal#")
				else
					table.insert(filenames, filename)
				end
			end
		end

		return string.format(" [ %s ] ", table.concat(filenames, ' | '))
	end

	local winbar = {
		"%#Normal#",
		format_buffer_list()
	}

	vim.o.winbar = table.concat(winbar, '')
end


vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = winbar_exec
})
