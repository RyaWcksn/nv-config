---@type vim.lsp.Config
return {
	cmd = { 'sqls' },
	filetypes = { 'sql' },
	root_markers = { 'config.yml', '.git' },
	on_attach = function(client, bufnr)
		local api = vim.api

		client.server_capabilities.executeCommandProvider = true
		client.server_capabilities.codeActionProvider = { resolveProvider = false }

		api.nvim_buf_create_user_command(bufnr, 'SqlsExecuteQuery', function(args)
			local range
			if args.range ~= 0 then
				local start_line = args.line1 - 1
				local end_line = args.line2 - 1
				local end_line_content = api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1] or
				    ''
				local end_char = #end_line_content
				range = {
					start = { line = start_line, character = 0 },
					['end'] = { line = end_line, character = end_char },
				}
			end

			client:request(
				vim.lsp.protocol.Methods.workspace_executeCommand,
				{
					command = 'executeQuery',
					arguments = { vim.uri_from_bufnr(0) },
					range = range,
				},
				function(err, result, ctx)
					if err then
						vim.notify('sqls: ' .. err.message, vim.log.levels.ERROR)
						return
					end
					if result then
						local tempname = vim.fn.tempname()
						vim.fn.writefile(vim.split(result, '\n'), tempname)
						vim.cmd('botright split ' .. tempname)
						vim.api.nvim_set_option_value('filetype', 'sqls_output', { buf = 0 })
						vim.api.nvim_set_option_value('buftype', 'nofile', { buf = 0 })
						vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = 0 })
					end
				end
			)
		end, { range = true })

		api.nvim_buf_create_user_command(bufnr, 'SqlsShowSchemas', function(args)
			client:request(
				vim.lsp.protocol.Methods.workspace_executeCommand,
				{
					command = 'showSchemas',
				},
				function(err, result, ctx)
					if err then
						vim.notify('sqls: ' .. err.message, vim.log.levels.ERROR)
						return
					end
					if result then
						local tempname = vim.fn.tempname()
						vim.fn.writefile(vim.split(result, '\n'), tempname)
						vim.cmd('pedit ' .. tempname)
					end
				end
			)
		end, {})

		api.nvim_buf_create_user_command(bufnr, 'SqlsShowTables', function(args)
			client:request(
				vim.lsp.protocol.Methods.workspace_executeCommand,
				{
					command = 'showTables',
				},
				function(err, result, ctx)
					if err then
						vim.notify('sqls: ' .. err.message, vim.log.levels.ERROR)
						return
					end
					if result then
						local tempname = vim.fn.tempname()
						vim.fn.writefile(vim.split(result, '\n'), tempname)
						vim.cmd('pedit ' .. tempname)
					end
				end
			)
		end, {})

		api.nvim_buf_create_user_command(bufnr, 'SqlsShowConnections', function(args)
			client:request(
				vim.lsp.protocol.Methods.workspace_executeCommand,
				{
					command = 'showConnections',
				},
				function(err, result, ctx)
					if err then
						vim.notify('sqls: ' .. err.message, vim.log.levels.ERROR)
						return
					end
					if result then
						local tempname = vim.fn.tempname()
						vim.fn.writefile(vim.split(result, '\n'), tempname)
						vim.cmd('pedit ' .. tempname)
					end
				end
			)
		end, {})

		api.nvim_buf_create_user_command(bufnr, 'SqlsSwitchConnection', function(args)
			client:request(
				vim.lsp.protocol.Methods.workspace_executeCommand,
				{
					command = 'showConnections',
				},
				function(err, result, ctx)
					if err then
						vim.notify('sqls: ' .. err.message, vim.log.levels.ERROR)
						return
					end
					if result then
						local choices = vim.split(result, '\n')
						vim.ui.select(choices, { prompt = 'Select Connection' }, function(choice)
							if choice then
								local conn_name = vim.split(choice, ' ')[1]
								client:request(
									vim.lsp.protocol.Methods
									.workspace_executeCommand,
									{
										command = 'switchConnections',
										arguments = { conn_name },
									},
									function(switch_err, _, _)
										if switch_err then
											vim.notify(
												'sqls: ' ..
												switch_err.message,
												vim.log.levels.ERROR)
										else
											vim.notify('Switched to: ' ..
												conn_name)
										end
									end
								)
							end
						end)
					end
				end
			)
		end, {})

		vim.keymap.set('n', '<leader>se', '<cmd>SqlsExecuteQuery<CR>',
			{ buffer = bufnr, desc = 'SQLs Execute Query' })
		vim.keymap.set('x', '<leader>se', '<cmd>SqlsExecuteQuery<CR>',
			{ buffer = bufnr, desc = 'SQLs Execute Query' })
		vim.keymap.set('n', '<leader>ss', '<cmd>SqlsShowSchemas<CR>',
			{ buffer = bufnr, desc = 'SQLs Show Schemas' })
		vim.keymap.set('n', '<leader>st', '<cmd>SqlsShowTables<CR>',
			{ buffer = bufnr, desc = 'SQLs Show Tables' })
		vim.keymap.set('n', '<leader>sc', '<cmd>SqlsSwitchConnection<CR>',
			{ buffer = bufnr, desc = 'SQLs Switch Connection' })
	end,
}
