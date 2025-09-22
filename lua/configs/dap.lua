local M = {}

M.setup = function()
	local dap = require("dap")
	require('dap').set_log_level('TRACE')

	vim.fn.sign_define("DapBreakpoint", {
		text = "B",
		texthl = "DiagnosticError",
		numhl = "",
	})

	vim.fn.sign_define("DapBreakpointRejected", {
		text = "B",
		texthl = "DiagnosticWarn",
		numhl = "",
	})

	vim.fn.sign_define("DapStopped", {
		text = "->",
		texthl = "DiagnosticHint",
		numhl = "",
	})

	vim.keymap.set("n", "<leader>do", function() require("dap").toggle_breakpoint() end,
		{ desc = "Toggle breakpoint" })
	vim.keymap.set("n", "<leader>dd", function() require("dap").continue() end, { desc = "Continue" })
	vim.keymap.set("n", "<leader>dk", function() require("dap").step_into() end, { desc = "Step into" })
	vim.keymap.set("n", "<leader>dj", function() require("dap").step_over() end, { desc = "Step over" })
	vim.keymap.set("n", "<leader>dl", function() require("dap").step_out() end, { desc = "Step out" })
	vim.keymap.set("n", "<leader>dt", function() require("dap").terminate() end, { desc = "Terminate" })
	vim.keymap.set("n", "<leader>db", function() require("dap").list_breakpoints() end, { desc = "List breakpoints" })
	local widgets = require("dap.ui.widgets")
	local scopes = widgets.sidebar(widgets.scopes, {}, "vsplit")
	local frames = widgets.sidebar(widgets.frames, { height = 10 }, "belowright split")
	local threads = widgets.sidebar(widgets.threads, {}, "right")
	local sessions = widgets.sidebar(widgets.sessions, {}, "right")
	local repl = require("dap.repl")

	vim.keymap.set("n", "<leader>da", function()
		return repl.toggle({}, "belowright split")
	end, { desc = "Open repl" })

	vim.keymap.set("n", "<leader>ds", scopes.toggle, { desc = "Open scopes" })
	vim.keymap.set("n", "<leader>df", frames.toggle, { desc = "Open frames" })
	vim.keymap.set("n", "<leader>dw", threads.toggle, { desc = "Open threads" })
	vim.keymap.set("n", "<leader>de", sessions.toggle, { desc = "Open sessions" })
	vim.keymap.set("n", "<leader>dh", widgets.hover, { desc = "Widget hover" })
	vim.keymap.set("n", "<leader>dv", function()
		vim.ui.input({ prompt = "Variable/field (e.g. v.a): " }, function(var)
			if not var or var == "" then return end
			vim.ui.input({ prompt = "New value for " .. var .. ": " }, function(val)
				if not val or val == "" then return end

				repl.execute("call " .. var .. " = " .. val)
			end)
		end)
	end, { desc = "Set variable value in dap repl" })

	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = "dap-repl",
		group = vim.api.nvim_create_augroup('dap_repl', { clear = true }),
		callback = function()
			require("dap.ext.autocompl").attach()
		end,
	})

	dap.adapters.delve = function(callback, config)
		local ok, err = pcall(function()
			if config.mode == "remote" and config.request == "attach" then
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or "38697",
				})
			else
				callback({
					type = "server",
					port = "${port}",
					executable = {
						command = "dlv",
						args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
						detached = vim.fn.has("win32") == 0,
					},
				})
			end
		end)
		if not ok then
			vim.notify("[DAP] Error setup delve adapter: " .. tostring(err), vim.log.levels.ERROR)
		end
	end

	dap.configurations.go = {
		{
			type = "delve",
			name = "Debug",
			request = "launch",
			program = "${file}"
		},
		{
			type = "delve",
			name = "Debug test",
			request = "launch",
			mode = "test",
			program = "${file}"
		},
		{
			type = "delve",
			name = "Debug test (go.mod)",
			request = "launch",
			mode = "test",
			program = "./${relativeFileDirname}"
		}
	}
end

return M
