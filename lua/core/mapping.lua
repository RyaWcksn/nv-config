local utils = require('utils.utils')
local opt = { silent = false, noremap = true }

-- Window
vim.keymap.set('n', '<leader>wk', "<c-w>k", { desc = "Switch Up" })
vim.keymap.set('n', '<leader>wj', "<c-w>j", { desc = "Switch Down" })
vim.keymap.set('n', '<leader>wh', "<c-w>h", { desc = "Switch Left" })
vim.keymap.set('n', '<leader>wl', "<c-w>l", { desc = "Switch Right" })

-- Folding
vim.keymap.set({ 'n' }, '<leader>kk', "zc", { desc = "Fold" })
vim.keymap.set({ 'n' }, '<leader>kh', "zR", { desc = "Unfold all" })
vim.keymap.set({ 'n' }, '<leader>kl', "zo", { desc = "Unfold" })

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

-- Git
local lazygit = function()
	utils.open_command('lazygit')
end
vim.keymap.set('n', '<leader>gg', lazygit, { desc = "Open lazygit" })
vim.keymap.set({ 'n', 'v' }, '<leader>gb', utils.git_blame_current_line, { desc = "Git Blame current line" })
vim.keymap.set('n', '<leader>gl', utils.find_and_switch_branch, { desc = "Find and switch git branch" })


-- Searching feature
local search_file = function()
	utils.get_file(function(selected_file)
		vim.cmd("e " .. vim.fn.fnameescape(selected_file))
	end)
end
vim.keymap.set('n', '<leader>ff', search_file, { desc = "Search file" })
vim.keymap.set('n', '<leader>fr', utils.search_and_replace, { desc = "Search and replace" })
vim.keymap.set('n', '<leader>fw', utils.search_words_and_qflist, { desc = "Search words in codebase" })

-- Buffer
vim.keymap.set('n', '<leader>bl', utils.buffers_to_quickfix, { desc = "List all buffers in quickfix list" })
vim.keymap.set('n', '<leader>bd', ":bd<CR>", { desc = "Delete This Buffer" })
vim.keymap.set({ 'n', 'v' }, '<leader>bb', utils.git_blame_current_line, { desc = "Git Blame current line" })
vim.keymap.set('n', '<leader>ba', ":w <bar> %bd <bar> e# <bar> bd# <CR>", { desc = "Delete All But This Buffer" })
vim.keymap.set('n', '<tab>', ":bn<CR>", { desc = "Next Buffer" })
vim.keymap.set('n', '<s-tab>', ":bp<CR>", { desc = "Prev Buffer" })
