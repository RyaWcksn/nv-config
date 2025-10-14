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
}
