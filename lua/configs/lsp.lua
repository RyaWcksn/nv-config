-- Enable LSP servers
vim.lsp.enable({
	"lua_ls",
	"gopls",
	"golangci_lint_ls",
	"ts_ls",
	"tailwindcss",
	"rust_analyzer"
})

local signs = { Error = "> ", Warn = "W ", Hint = "H ", Info = "I " }
for type, icon in ipairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local config = {
	virtual_text = {
		source = "always",
		prefix = '>',
	},
	signs = true,
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
	},
}
vim.diagnostic.config(config)

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		vim.lsp.set_log_level(vim.log.levels.ERROR)

		-- ========================
		-- Keymaps
		-- ========================
		vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { desc = "Format" })
		vim.keymap.set('n', '<leader>lc', vim.lsp.buf.code_action, { desc = "Code Action" })
		vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help, { desc = "Signature Help" })
		vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, { desc = "Goto Definition" })
		vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, { desc = "Code Implementation" })
		vim.keymap.set('n', '<leader>lw', vim.lsp.buf.references, { desc = "Code References" })
		vim.keymap.set('n', '<leader>ll', vim.lsp.codelens.run, { desc = "Codelens Run" })
		vim.keymap.set('n', '<leader>lL', vim.lsp.codelens.refresh, { desc = "Codelens Refresh" })
		vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { desc = "Rename" })
		vim.keymap.set('n', '<leader>lt', vim.diagnostic.setqflist, { desc = "Diagnostics" })
		vim.keymap.set('n', '<leader>lo', vim.lsp.buf.document_symbol, { desc = "Document Symbol" })
		vim.keymap.set('n', '<C-k>', vim.diagnostic.open_float, { desc = "Open diagnostic float" })

		vim.lsp.document_color.enable()

		-- ========================
		-- LSP Features per server capabilities
		-- ========================
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end

		if client:supports_method('textDocument/inlayHint') then
			vim.api.nvim_create_autocmd("InsertEnter", {
				buffer = ev.buf,
				callback = function() vim.lsp.inlay_hint.enable(true) end
			})
			vim.api.nvim_create_autocmd("InsertLeave", {
				buffer = ev.buf,
				callback = function() vim.lsp.inlay_hint.enable(false) end
			})
		end

		if client:supports_method('textDocument/codeLens') then
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
				buffer = ev.buf,
				callback = function() vim.lsp.codelens.refresh() end
			})
		end

		if client:supports_method('textDocument/documentHighlight') then
			vim.api.nvim_set_hl(ev.buf, 'LspReferenceRead', { link = 'Search' })
			vim.api.nvim_set_hl(ev.buf, 'LspReferenceText', { link = 'Search' })
			vim.api.nvim_set_hl(ev.buf, 'LspReferenceWrite', { link = 'Search' })

			vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
			vim.api.nvim_clear_autocmds({ buffer = ev.buf, group = 'lsp_document_highlight' })

			vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				group = 'lsp_document_highlight',
				buffer = ev.buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				group = 'lsp_document_highlight',
				buffer = ev.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end

		if not client:supports_method('textDocument/willSaveWaitUntil')
		    and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('neko.lsp', { clear = false }),
				buffer = ev.buf,
				callback = function()
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end,
			})
		end

		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = ev.buf,
			callback = function()
				vim.diagnostic.open_float(nil, {
					focusable = false,
					close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
					border = 'rounded',
					source = 'always',
					prefix = ' ',
					scope = 'line',
				})
			end
		})
	end,

})

-- ========================
-- User Commands
-- ========================
vim.api.nvim_create_user_command("LspStop", function(opts)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if opts.args == "" or opts.args == client.name then
			client:stop(true)
			vim.notify(client.name .. ": stopped")
		end
	end
end, {
	desc = "Stop all LSP clients or a specific client",
	nargs = "?",
	complete = function()
		local names = {}
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
			table.insert(names, c.name)
		end
		return names
	end
})

vim.api.nvim_create_user_command("LspRestart", function()
	local detach_clients = {}
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		client:stop(true)
		if vim.tbl_count(client.attached_buffers) > 0 then
			detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
		end
	end
	local timer = vim.uv.new_timer()
	if not timer then
		return vim.notify("Servers stopped but not restarted")
	end
	timer:start(100, 50, vim.schedule_wrap(function()
		for name, client in pairs(detach_clients) do
			local client_id = vim.lsp.start(client[1].config, { attach = false })
			if client_id then
				for _, buf in ipairs(client[2]) do
					vim.lsp.buf_attach_client(buf, client_id)
				end
				vim.notify(name .. ": restarted")
			end
			detach_clients[name] = nil
		end
		if not next(detach_clients) and not timer:is_closing() then
			timer:close()
		end
	end))
end, { desc = "Restart all LSP clients for current buffer" })

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.vsplit(vim.lsp.log.get_filename())
end, { desc = "Open LSP log file" })

vim.api.nvim_create_user_command("LspInfo", function()
	vim.cmd("silent checkhealth neko.lsp")
end, { desc = "Show LSP health info" })
