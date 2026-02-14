---@class TrackerOpts
---@field filter string[] filter filetype
---@field db_path string db location path

local M = {}

--- @type TrackerOpts
local config = {
	filter = {},
	db_path = "",
	last_activity = os.time(),
	project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
}

local function db_execute(sql)
	if config.db_path == "" then return end
	local full_path = vim.fn.expand(config.db_path)
	vim.fn.system(string.format('sqlite3 %s "%s"', full_path, sql))
end

local function get_git_branch()
	local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
	return branch ~= "" and branch or "no-branch"
end

local function track_activity()
	local now = os.time()
	local duration = now - config.last_activity

	local current_ft = vim.bo.filetype
	for _, ft in ipairs(config.filter) do
		if current_ft == ft then return end
	end

	if duration > 1 and duration < 300 then
		local branch = get_git_branch()
		local query = string.format(
			"INSERT INTO activity_log (project, branch, duration_sec) VALUES ('%s', '%s', %d);",
			config.project_name, branch, duration
		)
		db_execute(query)
	end

	config.last_activity = now
end


---Initiate tracker
---@param opts TrackerOpts filter and db location
function M.setup(opts)
	config.filter = opts.filter or {}
	config.db_path = opts.db_path or "~/tracker.db"

	db_execute([[
        CREATE TABLE IF NOT EXISTS activity_log (
            id INTEGER PRIMARY KEY,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            project TEXT,
            branch TEXT,
            duration_sec INTEGER
        );
    ]])

	local group = vim.api.nvim_create_augroup("WorkTracker", { clear = true })

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "TextChanged", "TextChangedI", "FocusLost" }, {
		group = group,
		callback = function()
			if (os.time() - config.last_activity) > 10 then
				track_activity()
			end
		end
	})

	vim.api.nvim_create_autocmd("VimLeave", {
		group = group,
		callback = track_activity
	})
end

return M
