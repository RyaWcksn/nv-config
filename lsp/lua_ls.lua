---@type vim.lsp.config
return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		'.emmyrc.json',
		'.luarc.json',
		'.luarc.jsonc',
		'.luacheckrc',
		'.stylua.toml',
		'stylua.toml',
		'selene.toml',
		'selene.yml',
		'.git',
	},
	telemetry = { enabled = false },
	settings = {
		Lua = {
			codeLens = { enable = true },
			hint = { enable = true, semicolon = 'Disable' },
			runtime = {
				version = "LuaJIT",
			},
		},
	},
}
