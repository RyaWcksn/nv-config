local M                  = {}
local api                = vim.api
local fn                 = vim.fn

M.create_floating_window = function(opts)
	opts = opts or {}
	local max_height = vim.api.nvim_win_get_height(0)
	local max_width = vim.api.nvim_win_get_width(0)
	local height = math.floor(max_height * 0.8)
	local width = math.floor(max_width * 0.8)
	local title = opts.title or "Floating"
	local border = opts.border or "rounded"
	local style = opts.style or "minimal"

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		height = height,
		width = width,
		row = (max_height - height) / 2,
		col = (max_width - width) / 2,
		style = style,
		border = border,
		title = title,
	})

	vim.api.nvim_create_autocmd("WinClosed", {
		once = true,
		callback = function()
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end,
	})
	return win, buf
end

M.get_file               = function(callback)
	local win, buf = M.create_floating_window()
	local tmpfile = vim.fn.tempname()
	vim.cmd(string.format(
		"terminal fzf --preview 'cat {}' > %s",
		vim.fn.shellescape(tmpfile)
	))

	vim.bo[buf].buflisted = false

	vim.api.nvim_create_autocmd("TermClose", {
		once = true,
		callback = function()
			local result = vim.fn.readfile(tmpfile)[1]
			os.remove(tmpfile)
			if result and callback then
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
				if vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_delete(buf, { force = true })
				end
				vim.schedule(function()
					callback(result)
				end)
			end
		end
	})
	vim.cmd('startinsert')
	vim.api.nvim_set_option_value("filetype", "findfile", {
		buf = 0
	})
end

M.open_command           = function(cmd)
	M.create_floating_window()
	local a = vim.cmd.term(cmd or nil)
	print(a)
	vim.cmd("startinsert")
end

M.open_file_tree         = function()
	vim.api.nvim_command('topleft vsplit')
	vim.api.nvim_win_set_width(0, 30)
	vim.cmd.edit('.')
end

M.git_blame_current_line = function()
	-- Determine visual or normal mode range
	local mode = vim.fn.mode()
	local start_line, end_line

	if mode == 'v' or mode == 'V' then
		-- Visual mode: get selected line range
		start_line = vim.fn.line("v")
		end_line = vim.fn.line(".")
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
		-- Exit visual mode
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	else
		-- Normal mode: just the current line
		start_line = vim.fn.line(".")
		end_line = start_line
	end

	local filepath = vim.fn.expand('%:p')
	local cmd = { 'git', 'blame', '--line-porcelain', '-L', start_line .. ',' .. end_line, filepath }

	local handle = io.popen(table.concat(cmd, ' '))
	if not handle then
		vim.notify("Failed to run git blame", vim.log.levels.ERROR)
		return
	end

	local output = handle:read("*a")
	handle:close()

	local messages = {}
	local current_author, current_summary
	local uncommitted_sha = "0000000000000000000000000000000000000000"

	for line in output:gmatch("[^\r\n]+") do
		if line:match("^" .. uncommitted_sha) then
			table.insert(messages, "Not committed")
		elseif line:match("^author ") then
			current_author = line:match("^author (.+)")
		elseif line:match("^summary ") then
			current_summary = line:match("^summary (.+)")
			if current_author and current_summary then
				table.insert(messages, current_author .. ": " .. current_summary)
				current_author, current_summary = nil, nil
			end
		end
	end

	if #messages == 0 then
		vim.notify("No blame info found", vim.log.levels.WARN)
	else
		vim.notify(table.concat(messages, "\n"), vim.log.levels.INFO, { title = "Git Blame" })
	end
end


M.search_and_replace     = function()
	local search = vim.fn.input("Search for: ")
	if search == "" then
		vim.notify("Nothing to search...", vim.log.levels.INFO)
		return
	end
	local replace = vim.fn.input("Replace with: ")
	local cmd = string.format('args `rg --files-with-matches "%s"` | argdo %%s/%s/%s/ge | update', search, search,
		replace)
	vim.cmd(cmd)
end

M.buffers_to_quickfix    = function()
	local buffers = vim.api.nvim_list_bufs() -- Get all buffers
	local quickfix_list = {}

	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) then
			local name = vim.api.nvim_buf_get_name(buf)
			if name ~= "" then -- Ignore unnamed buffers
				table.insert(quickfix_list, {
					filename = name,
					lnum = 1, -- Line number (default to 1)
					col = 1, -- Column number (default to 1)
					text = "Buffer: " .. name,
				})
			end
		end
	end

	if #quickfix_list == 0 then
		print("No active buffers to list.")
		return
	end

	-- Set the quickfix list
	vim.fn.setqflist(quickfix_list, 'r')
	vim.cmd("copen") -- Open the quickfix list window
	print("Buffers added to quickfix list.")
end

M.find_and_switch_branch = function()
	local win = M.create_floating_window()
	local branch_list_file = vim.fn.tempname()
	local result_file = vim.fn.tempname()

	-- Get all branches
	local get_branches_cmd = "git branch -a"
	local branches_raw = vim.fn.systemlist(get_branches_cmd)

	local branches_clean = {}
	for _, branch in ipairs(branches_raw) do
		local clean_branch = branch:gsub("^[ *]*", ""):gsub("remotes/origin/", "")
		table.insert(branches_clean, clean_branch)
	end

	-- get unique branches
	local branches_unique = {}
	local branches_set = {}
	for _, branch in ipairs(branches_clean) do
		if not branches_set[branch] then
			branches_set[branch] = true
			table.insert(branches_unique, branch)
		end
	end

	vim.fn.writefile(branches_unique, branch_list_file)

	local fzf_cmd = string.format(
		"cat %s | fzf --print-query --expect=enter > %s",
		vim.fn.shellescape(branch_list_file),
		vim.fn.shellescape(result_file)
	)
	vim.cmd("terminal " .. fzf_cmd)

	vim.api.nvim_create_autocmd("TermClose", {
		once = true,
		callback = function()
			vim.api.nvim_win_close(win, true)

			os.remove(branch_list_file)

			local result = vim.fn.readfile(result_file)
			os.remove(result_file)

			if #result < 2 then
				vim.notify("No branch selected", vim.log.levels.INFO)
				return
			end

			local key = result[1]
			local query = result[2]
			local selection = result[3]

			local branch_to_checkout
			if selection and selection ~= "" then
				branch_to_checkout = selection
			elseif query and query ~= "" then
				branch_to_checkout = query
			end

			if branch_to_checkout then
				local branch_exists = false
				for _, branch in ipairs(branches_unique) do
					if branch == branch_to_checkout then
						branch_exists = true
						break
					end
				end

				if branch_exists then
					-- checkout
					local checkout_cmd = "git checkout " .. vim.fn.shellescape(branch_to_checkout)
					local output = vim.fn.system(checkout_cmd)
					if vim.v.shell_error == 0 then
						vim.notify("Switched to branch: " .. branch_to_checkout,
							vim.log.levels.INFO)
					else
						vim.notify("Failed to switch to branch: " .. branch_to_checkout,
							vim.log.levels.ERROR)
						vim.notify(output, vim.log.levels.ERROR)
					end
				else
					-- create
					local create_cmd = "git checkout -b " .. vim.fn.shellescape(branch_to_checkout)
					local output = vim.fn.system(create_cmd)
					if vim.v.shell_error == 0 then
						vim.notify("Created and switched to new branch: " .. branch_to_checkout,
							vim.log.levels.INFO)
					else
						vim.notify("Failed to create branch: " .. branch_to_checkout,
							vim.log.levels.ERROR)
						vim.notify(output, vim.log.levels.ERROR)
					end
				end
			else
				vim.notify("No branch selected or created.", vim.log.levels.INFO)
			end
		end
	})
	vim.cmd('startinsert')
end


M.make_pair = function(open, close, opts)
	opts = opts or {}
	return function()
		local line = api.nvim_get_current_line()
		local col = fn.col('.') - 1
		local next_char = line:sub(col + 1, col + 1)
		local prev_char = line:sub(col, col)

		-- Jump over if next char is the closer
		if next_char == close then
			return "<Right>"
		end

		-- Skip pairing quotes after word characters
		if opts.skip_if_prev_word and prev_char:match("%w") then
			return open
		end

		-- Insert pair and go left
		return open .. close .. "<Left>"
	end
end

M.make_closer = function(ch)
	return function()
		local line = api.nvim_get_current_line()
		local col = fn.col('.') - 1
		local next_char = line:sub(col + 1, col + 1)
		if next_char == ch then
			return "<Right>"
		else
			return ch
		end
	end
end

return M
