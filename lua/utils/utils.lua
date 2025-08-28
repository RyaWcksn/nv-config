local M                   = {}
local api                 = vim.api
local fn                  = vim.fn

M.create_floating_window  = function(opts)
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

M.open_notes              = function(notes)
	local path, name = "", ""
	local case = {
		["todo"] = function()
			path = vim.fn.expand("~/notes/todo.md")
			name = "todo"
		end,
		["inspiration"] = function()
			path = vim.fn.expand("~/notes/inspiration.md")
			name = "inspiration"
		end,
		["done"] = function()
			path = vim.fn.expand("~/notes/done.md")
			name = "done"
		end,
		["journal"] = function()
			local notes_dir = vim.fn.expand("~/notes/journal")
			local date = os.date("%y-%m-%d")
			path = notes_dir .. "/" .. date .. ".md"
			name = "journal"
		end,
	}

	if case[notes] then
		case[notes]()
	else
		case["done"]()
	end

	local dir = vim.fn.fnamemodify(path, ":h")

	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	if vim.fn.filereadable(path) == 0 then
		local f = io.open(path, "w")
		if f then f:close() end
	end

	local opts = {
		title = "Notes " .. name
	}

	M.create_floating_window(opts)

	vim.api.nvim_command("edit " .. path)

	if notes == "journal" then
		local timestamp = "# " .. os.date("%H:%M:%S")

		vim.api.nvim_put({ timestamp }, "l", true, true)
	elseif notes ~= "done" then
		vim.cmd("startinsert")
	end

	vim.api.nvim_set_option_value("filetype", "notesfloat", {
		buf = 0
	})
	buf = vim.api.nvim_get_current_buf()
	vim.api.nvim_create_autocmd("WinClosed", {
		once = true,
		callback = function(args)
			if tonumber(args.match) == win and vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end,
	})
end

M.search_word             = function()
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
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end
	})
	vim.cmd('startinsert')
end

M.get_file                = function(callback)
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

M.open_command            = function(cmd)
	M.create_floating_window()
	local a = vim.cmd.term(cmd or nil)
	print(a)
	vim.cmd("startinsert")
end

M.open_file_tree          = function()
	vim.api.nvim_command('topleft vsplit')
	vim.api.nvim_win_set_width(0, 30)
	vim.cmd.edit('.')
end

M.git_blame_current_line  = function()
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

M.search                  = function()
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

M.search_and_replace      = function()
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

M.buffers_to_quickfix     = function()
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

M.open_daily_note         = function()
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

M.find_and_switch_branch  = function()
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


M.move_done_items = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local todo_lines = {}
	local done_lines = {}

	for _, line in ipairs(lines) do
		if line:match("^%s*%- %[x%]") then
			local timestamp = os.date("%Y-%m-%d %H:%M")
			local done_line = line .. "  ✅ (" .. timestamp .. ")"
			table.insert(done_lines, done_line)
		else
			table.insert(todo_lines, line)
		end
	end

	if #done_lines > 0 then
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, todo_lines)

		local done_file = vim.fn.expand("~/notes/done.md")

		local dir = vim.fn.fnamemodify(done_file, ":h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end

		local f = io.open(done_file, "a")
		if f then
			for _, l in ipairs(done_lines) do
				f:write(l .. "\n")
			end
			f:close()
		end
	end
end


return M
