local utils = require('utils.utils')
local opt = { silent = false, noremap = true }

-- Command mode
vim.keymap.set('n', '<Leader>;', ':', opt)

-- Window
vim.keymap.set('n', '<leader>wk', "<c-w>k", { desc = "Switch Up" })
vim.keymap.set('n', '<leader>wj', "<c-w>j", { desc = "Switch Down" })
vim.keymap.set('n', '<leader>wh', "<c-w>h", { desc = "Switch Left" })
vim.keymap.set('n', '<leader>wl', "<c-w>l", { desc = "Switch Right" })

-- Scrolling
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Folding
vim.keymap.set("n", "<leader>kk", function()
	local linenr = vim.fn.line(".")
	-- If there's no fold to be opened/closed, do nothing.
	if vim.fn.foldlevel(linenr) == 0 then
		return
	end

	-- Open recursively if closed, close if open.
	local cmd = vim.fn.foldclosed(linenr) == -1 and "zc" or "zO"
	vim.cmd("normal! " .. cmd)
end, { silent = true, desc = "Folds: Toggle" })

-- Basic
vim.keymap.set('n', '<leader>s', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader><leader>', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

-- Open
vim.keymap.set('n', '<leader>oo', utils.open_file_tree, { desc = "Filetree (left narrow split)" })
vim.keymap.set('n', '<leader>ot', utils.open_command, { desc = "Terminal" })

-- Move from bottom to top
vim.keymap.set("n", "J", "mzJ`z", opt)

-- Yank to EOL
vim.keymap.set("n", "Y", "y$", opt)

-- Quickfix
vim.keymap.set('n', '<C-l>', ":cnext<CR>", opt)
vim.keymap.set('n', '<C-h>', ":cprev<CR>", opt)

-- Search
vim.keymap.set('c', '<Tab>', function()
	if vim.fn.getcmdtype() == "/" or vim.fn.getcmdtype() == "?" then return '<CR>/<c-r>/' end
	return '<c-z>'
end, { expr = true, remap = true })
vim.keymap.set('c', '<S-Tab>', function()
	if vim.fn.getcmdtype() == "/" or vim.fn.getcmdtype() == "?" then return '<CR>?<c-r>/' end
	return '<S-Tab>'
end, { expr = true, remap = true })

-- Autocompletion
vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, noremap = true })

vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-y>"
	else
		return "<CR>"
	end
end, { expr = true, noremap = true })

-- Using jk as ESC
vim.keymap.set("t", "jk", "<C-\\><C-n>")
vim.keymap.set({ "i", "v" }, "jk", "<esc>")


-- Searching feature
vim.keymap.set('n', '<leader>ff', ":find ", { desc = "Search file" })
vim.keymap.set('n', '<leader>fr', utils.search_and_replace, { desc = "Search and replace" })
vim.keymap.set('n', '<leader>fw', ":Search ", { desc = "Search words in codebase" })
vim.keymap.set('n', '<leader>fa', ':find *<TAB>', { desc = "Search", remap = true })

-- Buffer
vim.keymap.set('n', '<leader>bl', utils.buffers_to_quickfix, { desc = "List all buffers in quickfix list" })
vim.keymap.set('n', '<leader>bd', ":bd<CR>", { desc = "Delete This Buffer" })
vim.keymap.set({ 'n', 'v' }, '<leader>bb', utils.git_blame_current_line, { desc = "Git Blame current line" })
vim.keymap.set('n', '<leader>ba', ":w <bar> %bd <bar> e# <bar> bd# <CR>", { desc = "Delete All But This Buffer" })
vim.keymap.set('n', '<tab>', ":bn<CR>", { desc = "Next Buffer" })
vim.keymap.set('n', '<s-tab>', ":bp<CR>", { desc = "Prev Buffer" })

-- searching
vim.keymap.set('c', '<Tab>', function()
	if vim.fn.getcmdtype() == "/" or vim.fn.getcmdtype() == "?" then return '<CR>/<c-r>/' end
	return '<c-z>'
end, { expr = true, remap = true })
vim.keymap.set('c', '<S-Tab>', function()
	if vim.fn.getcmdtype() == "/" or vim.fn.getcmdtype() == "?" then return '<CR>?<c-r>/' end
	return '<S-Tab>'
end, { expr = true, remap = true })

-- Autopairs
local map_opts = { expr = true, noremap = true, silent = true }

-- Openers
vim.keymap.set("i", "(", utils.make_pair("(", ")"), map_opts)
vim.keymap.set("i", "[", utils.make_pair("[", "]"), map_opts)
vim.keymap.set("i", "{", utils.make_pair("{", "}"), map_opts)
vim.keymap.set("i", '"', utils.make_pair('"', '"', { skip_if_prev_word = true }), map_opts)
vim.keymap.set("i", "'", utils.make_pair("'", "'", { skip_if_prev_word = true }), map_opts)
vim.keymap.set("i", "`", utils.make_pair("`", "`"), map_opts)

-- Closers
vim.keymap.set("i", ")", utils.make_closer(")"), map_opts)
vim.keymap.set("i", "]", utils.make_closer("]"), map_opts)
vim.keymap.set("i", "}", utils.make_closer("}"), map_opts)

-- Replace % with M
vim.keymap.set("n", "mm", "%")
vim.keymap.set("x", "m", "%")
vim.keymap.set("o", "m", "%")
