local palette = {
	base00 = '#0b0e14',
	base01 = '#131721',
	base02 = '#202229',
	base03 = '#3e4b59',
	base04 = '#bfbdb6',
	base05 = '#e6e1cf',
	base06 = '#ece8db',
	base07 = '#f2f0e7',
	base08 = '#f07178',
	base09 = '#ff8f40',
	base0A = '#ffb454',
	base0B = '#aad94c',
	base0C = '#95e6cb',
	base0D = '#59c2ff',
	base0E = '#d2a6ff',
	base0F = '#e6b450'
}

vim.cmd.highlight("clear")
vim.o.background = "dark"
vim.g.colors_name = "ayu"

local set_hl = vim.api.nvim_set_hl

set_hl(0, "Normal", { fg = palette.base05, bg = palette.base00 })
set_hl(0, "CursorLine", { bg = palette.base01 })
set_hl(0, "CursorLineNr", { fg = palette.base0A, bold = true })
set_hl(0, "LineNr", { fg = palette.base03 })
set_hl(0, "Visual", { bg = palette.base02 })
set_hl(0, "StatusLine", { fg = palette.base04, bg = palette.base02 })
set_hl(0, "StatusLineNC", { fg = palette.base03, bg = palette.base01 })
set_hl(0, "Pmenu", { fg = palette.base05, bg = palette.base01 })
set_hl(0, "PmenuSel", { fg = palette.base01, bg = palette.base0D })
set_hl(0, "VertSplit", { fg = palette.base02 })

set_hl(0, "Comment", { fg = palette.base03, italic = true })
set_hl(0, "Constant", { fg = palette.base09 })
set_hl(0, "String", { fg = palette.base0B })
set_hl(0, "Character", { fg = palette.base0B })
set_hl(0, "Number", { fg = palette.base09 })
set_hl(0, "Boolean", { fg = palette.base09 })
set_hl(0, "Float", { fg = palette.base09 })
set_hl(0, "Identifier", { fg = palette.base08 })
set_hl(0, "Function", { fg = palette.base0D })
set_hl(0, "Statement", { fg = palette.base08 })
set_hl(0, "Conditional", { fg = palette.base0E })
set_hl(0, "Repeat", { fg = palette.base0E })
set_hl(0, "Label", { fg = palette.base0A })
set_hl(0, "Operator", { fg = palette.base05 })
set_hl(0, "Keyword", { fg = palette.base0E })
set_hl(0, "Exception", { fg = palette.base08 })
set_hl(0, "PreProc", { fg = palette.base0A })
set_hl(0, "Include", { fg = palette.base0D })
set_hl(0, "Define", { fg = palette.base0E })
set_hl(0, "Macro", { fg = palette.base0E })
set_hl(0, "Type", { fg = palette.base0A })
set_hl(0, "StorageClass", { fg = palette.base0A })
set_hl(0, "Structure", { fg = palette.base0A })
set_hl(0, "Typedef", { fg = palette.base0A })
set_hl(0, "Special", { fg = palette.base0C })
set_hl(0, "SpecialComment", { fg = palette.base03, italic = true })
set_hl(0, "Underlined", { fg = palette.base0D, underline = true })
set_hl(0, "Todo", { fg = palette.base0A, bold = true })
set_hl(0, "Error", { fg = palette.base08, bg = palette.base00, bold = true })

set_hl(0, "@function", { fg = palette.base0D })
set_hl(0, "@function.call", { fg = palette.base0D })
set_hl(0, "@type", { fg = palette.base0A })
set_hl(0, "@variable", { fg = palette.base05 })
set_hl(0, "@keyword", { fg = palette.base0E })
set_hl(0, "@string", { fg = palette.base0B })
set_hl(0, "@comment", { fg = palette.base03, italic = true })
set_hl(0, "@parameter", { fg = palette.base08 })
set_hl(0, "DiagnosticError", { fg = palette.base08 })
set_hl(0, "DiagnosticWarn", { fg = palette.base0A })
set_hl(0, "DiagnosticInfo", { fg = palette.base0D })
set_hl(0, "DiagnosticHint", { fg = palette.base0C })
