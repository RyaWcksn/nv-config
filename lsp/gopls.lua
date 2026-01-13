---@type vim.lsp.Config
return {
	cmd = { 'gopls' },
	filetypes = { 'go' },
	root_markers = { 'go.work', 'go.mod' },
	settings = {
		gopls = {
			env = {
				GOMEMLIMIT = "512MiB",
			},
			directoryFilters = {
				"-**/vendor",
				"-**/node_modules",
				"-**/third_party",
				"-**/testdata",
				"-**/tmp",
			},
			semanticTokens = false,
			diagnosticsDelay = "1s",
			experimentalPostfixCompletions = false,
			gofumpt = true,
			analyses = {
				unusedparams = true,
				nilness = false,
				shadow = false,
			},
			codelenses = {
				test = true,
				tidy = false,
			},
			staticcheck = false,
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
	on_attach = function(c, b)
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "go",
			callback = function()
				vim.api.nvim_create_user_command("ModifyTags", function(opts)
					local argv = vim.split(opts.args, "%s+")
					local parsed = {}

					local i = 1
					while i <= #argv do
						local arg = argv[i]
						if vim.startswith(arg, "-") then
							local flag = arg:sub(2)
							local val = argv[i + 1]
							if not val or vim.startswith(val, "-") then
								parsed[flag] = true
								i = i + 1
							else
								parsed[flag] = val
								i = i + 2
							end
						else
							i = i + 1
						end
					end

					if not parsed.file then
						parsed.file = vim.fn.expand("%:p")
					else
						parsed.file = vim.fn.fnamemodify(parsed.file, ":p")
					end

					if not parsed.struct then
						parsed.struct = vim.fn.expand("<cword>")
					end

					local cmd = { "gomodifytags" }
					for k, v in pairs(parsed) do
						if v == true then
							table.insert(cmd, "-" .. k)
						else
							table.insert(cmd, "-" .. k)
							table.insert(cmd, v)
						end
					end

					local output = vim.fn.system(cmd)

					if vim.v.shell_error ~= 0 then
						vim.api.nvim_echo("gomodifytags failed: " .. output, true, { err = true })
						return
					end

					local lines = vim.split(output, "\n", { trimempty = true })
					vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
				end, {
					desc = "Modify struct tags using gomodifytags",
					nargs = "+",
					complete = function(_, _, _)
						return { "-file", "-struct", "-add-tags", "-remove-tags", "-clear-tags" }
					end
				})
			end
		})
	end
}
