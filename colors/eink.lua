local colors = {
	bg        = "#f8f8f8",
	fg        = "#181818",
	black     = "#181818",
	darkgray  = "#383838",
	gray      = "#585858",
	midgray   = "#787878",
	lightgray = "#989898",
	lighter   = "#b8b8b8",
	pale      = "#d8d8d8",
	white     = "#ffffff",
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end
vim.o.background = "light"
vim.g.colors_name = "eink"

local function hi(group, opts)
	local cmd = { "hi", group }
	if opts.fg then table.insert(cmd, "guifg=" .. opts.fg) end
	if opts.bg then table.insert(cmd, "guibg=" .. opts.bg) end
	if opts.gui then table.insert(cmd, "gui=" .. opts.gui) end
	vim.cmd(table.concat(cmd, " "))
end

-- Core UI
hi("Normal", { fg = colors.fg, bg = colors.bg })
hi("LineNr", { fg = colors.gray })
hi("CursorLineNr", { fg = colors.fg, gui = "bold" })
hi("CursorLine", { bg = colors.pale })
hi("Visual", { bg = colors.lightgray })

-- Statusline & splits
hi("StatusLine", { fg = colors.fg, bg = colors.pale })
hi("StatusLineNC", { fg = colors.gray, bg = colors.pale })
hi("VertSplit", { fg = colors.gray, bg = colors.bg })

-- Search
hi("Search", { fg = colors.bg, bg = colors.midgray })
hi("IncSearch", { fg = colors.bg, bg = colors.darkgray })

-- Syntax (grayscale tiers)
hi("Comment", { fg = colors.gray, gui = "italic" })
hi("Identifier", { fg = colors.fg })
hi("Statement", { fg = colors.darkgray, gui = "bold" })
hi("PreProc", { fg = colors.midgray })
hi("Type", { fg = colors.darkgray })
hi("Special", { fg = colors.lightgray })
hi("Underlined", { fg = colors.fg, gui = "underline" })

-- Diagnostics (LSP)
hi("DiagnosticError", { fg = colors.darkgray })
hi("DiagnosticWarn", { fg = colors.midgray })
hi("DiagnosticInfo", { fg = colors.gray })
hi("DiagnosticHint", { fg = colors.lightgray })

-- Treesitter extras
hi("@variable", { fg = colors.fg })
hi("@function", { fg = colors.darkgray })
hi("@keyword", { fg = colors.darkgray, gui = "bold" })
hi("@string", { fg = colors.gray })
hi("@comment", { fg = colors.gray, gui = "italic" })

-- Terminal colors
vim.g.terminal_color_0  = colors.black
vim.g.terminal_color_1  = colors.darkgray
vim.g.terminal_color_2  = colors.gray
vim.g.terminal_color_3  = colors.midgray
vim.g.terminal_color_4  = colors.lightgray
vim.g.terminal_color_5  = colors.lighter
vim.g.terminal_color_6  = colors.pale
vim.g.terminal_color_7  = colors.white
vim.g.terminal_color_8  = colors.darkgray
vim.g.terminal_color_9  = colors.gray
vim.g.terminal_color_10 = colors.midgray
vim.g.terminal_color_11 = colors.lightgray
vim.g.terminal_color_12 = colors.lighter
vim.g.terminal_color_13 = colors.pale
vim.g.terminal_color_14 = colors.white
vim.g.terminal_color_15 = colors.white
