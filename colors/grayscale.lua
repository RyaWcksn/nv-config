local c = {
	bg = "#0B0E0B",
	fg = "#C9C9C9",
	cursor = "#2B2B2B",
	cursor_text = "#E0E0E0",


	color0 = "#0B0E0B",
	color1 = "#A0A0A0",
	color2 = "#B0B0B0",
	color3 = "#C0C0C0",
	color4 = "#D0D0D0",
	color5 = "#E0E0E0",
	color6 = "#F0F0F0",
	color7 = "#C9C9C9",


	color8 = "#2B2B2B",
	color9 = "#A0A0A0",
	color10 = "#B0B0B0",
	color11 = "#C0C0C0",
	color12 = "#D0D0D0",
	color13 = "#E0E0E0",
	color14 = "#F0F0F0",
	color15 = "#F5F5F5",
	color16 = "#FFFFFF",
}

local function hi(group, fg, bg, style)
	local cmd = { "hi", group }
	if fg then table.insert(cmd, "guifg=" .. fg) end
	if bg then table.insert(cmd, "guibg=" .. bg) end
	if style then table.insert(cmd, "gui=" .. style) end
	vim.cmd(table.concat(cmd, " "))
end

vim.cmd("highlight clear")
vim.cmd("set termguicolors")
vim.g.colors_name = "grayscale"

hi("Normal", c.fg, c.bg)
hi("Cursor", c.cursor_text, c.cursor, "bold")
hi("CursorLine", nil, c.cursor)
hi("CursorLineNr", c.fg, c.cursor, "bold")
hi("LineNr", c.color8, c.bg)
hi("Visual", nil, c.color8)
hi("Search", c.bg, c.color3)
hi("IncSearch", c.bg, c.color5)
hi("MatchParen", c.color16, c.cursor, "bold")

hi("Comment", c.color8, nil, "italic")
hi("Constant", c.color5)
hi("String", c.color10)
hi("Identifier", c.color11)
hi("Function", c.color16)
hi("Statement", c.color12)
hi("Keyword", c.color12, nil, "bold")
hi("Type", c.color2)
hi("Special", c.color6)
hi("Error", c.color4, c.bg, "bold")
hi("Todo", c.bg, c.color16, "bold")

hi("Pmenu", c.fg, c.cursor)
hi("PmenuSel", c.bg, c.color16, "bold")
hi("StatusLine", c.fg, c.cursor)
hi("StatusLineNC", c.color8, c.bg)
hi("VertSplit", c.cursor, c.bg)
hi("TabLine", c.color8, c.bg)
hi("TabLineSel", c.fg, c.cursor)
hi("TabLineFill", nil, c.bg)
