local wk = require("which-key")
wk.setup {
	icons = {
		mappings = false
	}
}

wk.add({
	{
		{ "<leader>b", group = "Buffer", remap = false },
		{ "<leader>f", group = "Finds",  remap = false },
		{ "<leader>l", group = "LSP",    remap = false },
		{ "<leader>n", group = "Notes",  remap = false },
		{ "<leader>g", group = "Git",    remap = false },
		{ "<leader>o", group = "Open",   remap = false },
		-- { "<leader>s", group = "DB",     remap = false },
		{ "<leader>w", group = "Window", remap = false },
		{ "<leader>k", group = "Fold",   remap = false },
		{ "<leader>;", group = "Command",   remap = false },
	}

}, { prefix = "<leader>", mode = "n", noremap = true })



wk.add({
	{
		{ "<leader>b", group = "Buffer", remap = false },
	}

}, { prefix = "<leader>", mode = "v", noremap = true })
