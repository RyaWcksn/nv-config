local M = {}

M.create_floating_window = function()
	local max_height = vim.api.nvim_win_get_height(0)
	local max_width = vim.api.nvim_win_get_width(0)
	local height = math.floor(max_height * 0.8)
	local width = math.floor(max_width * 0.8)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		height = height,
		width = width,
		row = (max_height - height) / 2,
		col = (max_width - width) / 2,
		style = "minimal",
		border = "rounded",
	})
	return win
end

M.search_and_qflist_names = function()
	local win = M.create_floating_window()
	local tmpfile = vim.fn.tempname()
	local cmd = string.format(
		"rg --vimgrep '' | fzf --multi --with-nth=4.. --delimiter=':' --bind 'enter:select-all+accept' > %s",
		vim.fn.shellescape(tmpfile)
	)

	vim.cmd("terminal " .. cmd)

	vim.api.nvim_create_autocmd("TermClose", {
		once = true,
		callback = function()
			local results = vim.fn.readfile(tmpfile)
			local qf_entries = {}
			for _, line in ipairs(results) do
				local filename, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
				if filename and lnum and col and text then
					table.insert(qf_entries, {
						filename = filename,
						lnum = tonumber(lnum),
						col = tonumber(col),
						text = text
					})
				end
			end
			if #qf_entries > 0 then
				vim.api.nvim_win_close(win, true)
				vim.fn.setqflist(qf_entries, "r")
				vim.cmd("copen")
			else
				vim.notify("No matches found", vim.log.levels.INFO)
			end
		end
	})
	vim.cmd('startinsert')
end

M.get_file = function(callback)
	local win = M.create_floating_window()
	local tmpfile = vim.fn.tempname()

	vim.cmd(string.format(
		"terminal fzf --preview 'cat {}' > %s",
		vim.fn.shellescape(tmpfile)
	))

	vim.api.nvim_create_autocmd("TermClose", {
		once = true,
		callback = function()
			local result = vim.fn.readfile(tmpfile)[1]
			os.remove(tmpfile)
			if result and callback then
				vim.api.nvim_win_close(win, true)
				vim.schedule(function()
					callback(result)
				end)
			end
		end
	})
	vim.cmd('startinsert')
end

M.open_command = function(cmd)
	M.create_floating_window()
	local a = vim.cmd.term(cmd or nil)
	print(a)
	vim.cmd("startinsert")
end

M.open_file_tree = function()
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

M.search = function()
	local search = vim.fn.input("Search for: ")
	-- Escape special shell characters for safe execution
	local escaped_input = search:gsub("'", [["]])

	-- Use ripgrep to search string content in files
	local cmd = "rg --vimgrep --smart-case '" .. escaped_input .. "'"
	local results = vim.fn.systemlist(cmd)

	if vim.v.shell_error ~= 0 then
		vim.notify("No matches found for '" .. search .. "'", vim.log.levels.WARN)
		return
	end

	vim.fn.setqflist({}, ' ', {
		title = 'Search Results',
		lines = results,
	})
	vim.cmd("copen")
end

M.search_and_replace = function()
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

M.buffers_to_quickfix = function()
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

M.file_picker = function()
	vim.ui.input({ prompt = "Search filenames > " }, function(input)
		if not input or input == "" then return end

		local cmd = { "rg", "--files" }

		vim.fn.setqflist({}, "r")

		vim.fn.jobstart(cmd, {
			cwd = vim.fn.getcwd(),
			stdout_buffered = true,
			on_stdout = function(_, data)
				if not data then return end

				local matches = {}
				for _, filepath in ipairs(data) do
					if filepath ~= "" and filepath:lower():find(input:lower(), 1, true) then
						table.insert(matches, {
							filename = filepath,
							lnum = 1,
							col = 1,
							text = filepath,
						})
					end
				end

				if #matches > 0 then
					vim.fn.setqflist(matches, "r")
					vim.cmd("copen")
					vim.api.nvim_create_autocmd("BufEnter", {
						pattern = "*",
						once = true,
						callback = function()
							-- Check if quickfix window is open, then close it
							for _, win in ipairs(vim.api.nvim_list_wins()) do
								if vim.fn.getwininfo(win)[1].quickfix == 1 then
									vim.api.nvim_win_close(win, false)
								end
							end
						end,
					})
				else
					vim.notify("No matching files for: " .. input, vim.log.levels.INFO)
				end
			end,

		})
	end)
end

M.open_daily_note = function()
	local notes_dir = vim.fn.expand("~/Notes/Journal") -- Change this to your Notes directory
	local date = os.date("%y-%m-%d")
	local filepath = notes_dir .. "/" .. date .. ".md"
	local timestamp = "## " .. os.date("%H:%M:%S")
	local datestamp = "# " .. date

	vim.cmd("edit " .. filepath)
	if vim.fn.filereadable(filepath) == 0 then
		vim.api.nvim_put({ datestamp, timestamp }, "l", true, true)
	else
		vim.cmd("normal G")
		vim.api.nvim_put({ timestamp }, "l", true, true)
		vim.cmd("normal G")
	end
end

M.search_words_and_qflist = function()
	local win = M.create_floating_window()
	local selected_words_file = vim.fn.tempname()

	local fzf_cmd = string.format(
		"rg -o -N --no-filename '[a-zA-Z_][a-zA-Z_0-9]*' . | sort -u | fzf --multi --bind 'enter:select-all+accept' > %s",
		vim.fn.shellescape(selected_words_file)
	)
	vim.cmd("terminal " .. fzf_cmd)

	vim.api.nvim_create_autocmd("TermClose", {
		once = true,
		callback = function()
			vim.api.nvim_win_close(win, true)

			local selected_words = vim.fn.readfile(selected_words_file)
			os.remove(selected_words_file)

			if #selected_words == 0 then
				vim.notify("No words selected", vim.log.levels.INFO)
				return
			end

			local all_results = {}
			for _, word in ipairs(selected_words) do
				if word ~= "" then
					local search_cmd = "rg --vimgrep " .. vim.fn.shellescape(word)
					local results = vim.fn.systemlist(search_cmd)
					for _, res in ipairs(results) do
						table.insert(all_results, res)
					end
				end
			end

			if #all_results == 0 then
				vim.notify("No matches found for the selected words", vim.log.levels.WARN)
				return
			end

			vim.fn.setqflist({}, 'r', {
				title = 'Search Results',
				lines = all_results,
			})
			vim.cmd("copen")
		end
	})
	vim.cmd('startinsert')
end

return M
