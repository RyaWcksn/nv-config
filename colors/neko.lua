local c = {
  bg          = "#0B0E14",
  fg          = "#c9c7be",
  cursor      = "#2b2e34",
  cursor_text = "#D9D7CE",

  color0  = "#0B0E14",
  color1  = "#c9c7be",
  color2  = "#AAD84C",
  color3  = "#56c3f9",
  color4  = "#F07174",
  color5  = "#FFB454",
  color6  = "#FFB454",
  color7  = "#c9c7be",

  color8  = "#2b2e34",
  color9  = "#c9c7be",
  color10 = "#AAD84C",
  color11 = "#56c3f9",
  color12 = "#F07174",
  color13 = "#FFB454",
  color14 = "#FFB454",
  color15 = "#E6E1CF",
  color16 = "#CBA6F7",
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
vim.g.colors_name = "neko"

hi("Normal",      c.fg, c.bg)
hi("Cursor",      c.cursor_text, c.cursor, "bold")
hi("CursorLine",  nil, c.cursor)
hi("CursorLineNr",c.fg, c.cursor, "bold")
hi("LineNr",      c.color8, c.bg)
hi("Visual",      nil, c.color8)
hi("Search",      c.bg, c.color3)
hi("IncSearch",   c.bg, c.color5)
hi("MatchParen",  c.color16, c.cursor, "bold")

hi("Comment",     c.color8, nil, "italic")
hi("Constant",    c.color5)
hi("String",      c.color10)
hi("Identifier",  c.color11)
hi("Function",    c.color16)
hi("Statement",   c.color12)
hi("Keyword",     c.color12, nil, "bold")
hi("Type",        c.color2)
hi("Special",     c.color6)
hi("Error",       c.color4, c.bg, "bold")
hi("Todo",        c.bg, c.color16, "bold")

hi("Pmenu",       c.fg, c.cursor)
hi("PmenuSel",    c.bg, c.color16, "bold")
hi("StatusLine",  c.fg, c.cursor)
hi("StatusLineNC",c.color8, c.bg)
hi("VertSplit",   c.cursor, c.bg)
hi("TabLine",     c.color8, c.bg)
hi("TabLineSel",  c.fg, c.cursor)
hi("TabLineFill", nil, c.bg)

