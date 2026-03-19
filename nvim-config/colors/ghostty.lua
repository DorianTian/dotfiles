-- Ghostty-native colorscheme for Neovim
-- Reads Ghostty's current theme file and generates highlights from its 16 ANSI colors.
-- Keeps termguicolors=true for full 24-bit rendering, but all colors come from Ghostty's palette.
-- Use :GhosttyReload to refresh after changing Ghostty theme, or it auto-refreshes on FocusGained.

-- ── helpers ──────────────────────────────────────────────────────────────

local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function blend(hex1, hex2, ratio)
  local r1, g1, b1 = hex_to_rgb(hex1)
  local r2, g2, b2 = hex_to_rgb(hex2)
  return rgb_to_hex(
    math.floor(r1 * (1 - ratio) + r2 * ratio),
    math.floor(g1 * (1 - ratio) + g2 * ratio),
    math.floor(b1 * (1 - ratio) + b2 * ratio)
  )
end

local function is_light(hex)
  local r, g, b = hex_to_rgb(hex)
  return (0.299 * r + 0.587 * g + 0.114 * b) > 128
end

-- ── Ghostty config parsing ──────────────────────────────────────────────

local function get_theme_name()
  local f = io.open(vim.fn.expand("~/.config/ghostty/config"), "r")
  if not f then return nil end

  for line in f:lines() do
    local theme = line:match("^theme%s*=%s*(.+)%s*$")
    if theme then
      f:close()
      theme = vim.trim(theme)
      -- handle light:X,dark:Y or dark:X,light:Y
      local light = theme:match("light:([^,]+)")
      local dark = theme:match("dark:([^,]+)")
      if light and dark then
        return vim.o.background == "light" and vim.trim(light) or vim.trim(dark)
      end
      return theme
    end
  end
  f:close()
  return nil
end

local function parse_theme(name)
  if not name then return nil end

  local search_paths = {
    vim.fn.expand("~/.config/ghostty/themes/" .. name),
    "/Applications/Ghostty.app/Contents/Resources/ghostty/themes/" .. name,
  }

  local f
  for _, path in ipairs(search_paths) do
    f = io.open(path, "r")
    if f then break end
  end
  if not f then return nil end

  local c = { palette = {} }
  for line in f:lines() do
    local idx, hex = line:match("^palette%s*=%s*(%d+)=(%S+)")
    if idx then
      c.palette[tonumber(idx)] = hex
    end
    local key, val = line:match("^(%S+)%s*=%s*(%S+)")
    if key == "background" then c.bg = val end
    if key == "foreground" then c.fg = val end
    if key == "cursor-color" then c.cursor = val end
    if key == "selection-background" then c.sel_bg = val end
    if key == "selection-foreground" then c.sel_fg = val end
  end
  f:close()

  -- sanity check
  if not c.bg or not c.fg then return nil end
  for i = 0, 15 do
    if not c.palette[i] then return nil end
  end

  return c
end

-- ── highlight application ───────────────────────────────────────────────

local function apply(c)
  vim.cmd("highlight clear")

  local p = c.palette
  local bg, fg = c.bg, c.fg

  vim.o.background = is_light(bg) and "light" or "dark"

  -- palette aliases
  local black, red, green, yellow = p[0], p[1], p[2], p[3]
  local blue, magenta, cyan, white = p[4], p[5], p[6], p[7]
  local br_black, br_red, br_green, br_yellow = p[8], p[9], p[10], p[11]
  local br_blue, br_magenta, br_cyan, br_white = p[12], p[13], p[14], p[15]

  -- derived
  local dim1 = blend(bg, fg, 0.06)
  local dim2 = blend(bg, fg, 0.12)
  local dim_fg = blend(bg, fg, 0.4)
  local sel = c.sel_bg or blend(bg, blue, 0.25)

  local hi = function(name, opts) vim.api.nvim_set_hl(0, name, opts) end

  -- ── UI ──

  hi("Normal",        { fg = fg, bg = bg })
  hi("NormalFloat",   { fg = fg, bg = dim1 })
  hi("FloatBorder",   { fg = br_black, bg = dim1 })
  hi("FloatTitle",    { fg = fg, bg = dim1, bold = true })
  hi("Cursor",        { fg = bg, bg = c.cursor or fg })
  hi("CursorLine",    { bg = dim1 })
  hi("CursorColumn",  { bg = dim1 })
  hi("ColorColumn",   { bg = dim1 })
  hi("LineNr",        { fg = br_black })
  hi("CursorLineNr",  { fg = yellow, bold = true })
  hi("SignColumn",    { fg = br_black, bg = bg })
  hi("VertSplit",     { fg = br_black })
  hi("WinSeparator",  { fg = br_black })
  hi("StatusLine",    { fg = fg, bg = dim2 })
  hi("StatusLineNC",  { fg = br_black, bg = dim1 })
  hi("TabLine",       { fg = br_black, bg = dim1 })
  hi("TabLineSel",    { fg = fg, bg = bg, bold = true })
  hi("TabLineFill",   { bg = dim1 })
  hi("WinBar",        { fg = fg, bold = true })
  hi("WinBarNC",      { fg = br_black })
  hi("Pmenu",         { fg = fg, bg = dim1 })
  hi("PmenuSel",      { fg = fg, bg = dim2, bold = true })
  hi("PmenuSbar",     { bg = dim2 })
  hi("PmenuThumb",    { bg = br_black })
  hi("Search",        { fg = bg, bg = yellow })
  hi("IncSearch",     { fg = bg, bg = br_yellow })
  hi("CurSearch",     { fg = bg, bg = br_yellow, bold = true })
  hi("Visual",        { bg = sel })
  hi("VisualNOS",     { bg = sel })
  hi("MatchParen",    { fg = br_yellow, bold = true, underline = true })
  hi("Folded",        { fg = br_black, bg = dim1 })
  hi("FoldColumn",    { fg = br_black })
  hi("NonText",       { fg = dim2 })
  hi("Whitespace",    { fg = dim2 })
  hi("SpecialKey",    { fg = br_black })
  hi("Conceal",       { fg = br_black })
  hi("Directory",     { fg = blue })
  hi("Title",         { fg = blue, bold = true })
  hi("Question",      { fg = green })
  hi("MoreMsg",       { fg = green })
  hi("WarningMsg",    { fg = yellow })
  hi("ErrorMsg",      { fg = bg, bg = red })
  hi("ModeMsg",       { fg = fg, bold = true })

  -- ── Diff ──

  hi("DiffAdd",    { bg = blend(bg, green, 0.15) })
  hi("DiffChange", { bg = blend(bg, yellow, 0.10) })
  hi("DiffDelete", { fg = red, bg = blend(bg, red, 0.10) })
  hi("DiffText",   { bg = blend(bg, yellow, 0.25) })
  hi("Added",      { fg = green })
  hi("Changed",    { fg = yellow })
  hi("Removed",    { fg = red })

  -- ── Diagnostics ──

  hi("DiagnosticError",              { fg = red })
  hi("DiagnosticWarn",               { fg = yellow })
  hi("DiagnosticInfo",               { fg = blue })
  hi("DiagnosticHint",               { fg = cyan })
  hi("DiagnosticOk",                 { fg = green })
  hi("DiagnosticUnderlineError",     { sp = red, undercurl = true })
  hi("DiagnosticUnderlineWarn",      { sp = yellow, undercurl = true })
  hi("DiagnosticUnderlineInfo",      { sp = blue, undercurl = true })
  hi("DiagnosticUnderlineHint",      { sp = cyan, undercurl = true })

  -- ── Spelling ──

  hi("SpellBad",   { sp = red, undercurl = true })
  hi("SpellCap",   { sp = yellow, undercurl = true })
  hi("SpellRare",  { sp = cyan, undercurl = true })
  hi("SpellLocal", { sp = green, undercurl = true })

  -- ── Standard syntax ──

  hi("Comment",      { fg = br_black, italic = true })
  hi("Constant",     { fg = cyan })
  hi("String",       { fg = green })
  hi("Character",    { fg = green })
  hi("Number",       { fg = br_cyan })
  hi("Boolean",      { fg = cyan, bold = true })
  hi("Float",        { fg = br_cyan })
  hi("Identifier",   { fg = blue })
  hi("Function",     { fg = blue, bold = true })
  hi("Statement",    { fg = magenta })
  hi("Conditional",  { fg = magenta })
  hi("Repeat",       { fg = magenta })
  hi("Label",        { fg = magenta })
  hi("Operator",     { fg = fg })
  hi("Keyword",      { fg = magenta, bold = true })
  hi("Exception",    { fg = red })
  hi("PreProc",      { fg = br_magenta })
  hi("Include",      { fg = magenta })
  hi("Define",       { fg = magenta })
  hi("Macro",        { fg = br_magenta })
  hi("PreCondit",    { fg = magenta })
  hi("Type",         { fg = yellow })
  hi("StorageClass", { fg = yellow })
  hi("Structure",    { fg = yellow })
  hi("Typedef",      { fg = yellow })
  hi("Special",      { fg = br_cyan })
  hi("SpecialChar",  { fg = cyan })
  hi("Tag",          { fg = red })
  hi("Delimiter",    { fg = fg })
  hi("SpecialComment", { fg = br_black, bold = true })
  hi("Debug",        { fg = red })
  hi("Underlined",   { fg = blue, underline = true })
  hi("Ignore",       { fg = br_black })
  hi("Error",        { fg = bg, bg = red })
  hi("Todo",         { fg = bg, bg = yellow, bold = true })

  -- ── Treesitter ──

  hi("@variable",                    { fg = fg })
  hi("@variable.builtin",           { fg = red })
  hi("@variable.parameter",         { fg = br_blue })
  hi("@variable.member",            { fg = fg })
  hi("@constant",                   { fg = cyan })
  hi("@constant.builtin",           { fg = cyan, bold = true })
  hi("@constant.macro",             { fg = br_cyan })
  hi("@module",                     { fg = blue })
  hi("@module.builtin",             { fg = blue, italic = true })
  hi("@label",                      { fg = magenta })
  hi("@string",                     { fg = green })
  hi("@string.documentation",       { fg = br_green, italic = true })
  hi("@string.regexp",              { fg = br_cyan })
  hi("@string.escape",              { fg = cyan })
  hi("@string.special",             { fg = cyan })
  hi("@character",                  { fg = green })
  hi("@character.special",          { fg = cyan })
  hi("@boolean",                    { fg = cyan, bold = true })
  hi("@number",                     { fg = br_cyan })
  hi("@number.float",               { fg = br_cyan })
  hi("@type",                       { fg = yellow })
  hi("@type.builtin",               { fg = yellow, italic = true })
  hi("@type.definition",            { fg = yellow })
  hi("@attribute",                  { fg = br_yellow })
  hi("@attribute.builtin",          { fg = br_yellow, italic = true })
  hi("@property",                   { fg = fg })
  hi("@function",                   { fg = blue, bold = true })
  hi("@function.builtin",           { fg = blue })
  hi("@function.call",              { fg = blue })
  hi("@function.macro",             { fg = br_magenta })
  hi("@function.method",            { fg = blue })
  hi("@function.method.call",       { fg = blue })
  hi("@constructor",                { fg = yellow })
  hi("@operator",                   { fg = fg })
  hi("@keyword",                    { fg = magenta, bold = true })
  hi("@keyword.coroutine",          { fg = magenta })
  hi("@keyword.function",           { fg = magenta })
  hi("@keyword.operator",           { fg = magenta })
  hi("@keyword.import",             { fg = magenta })
  hi("@keyword.type",               { fg = yellow })
  hi("@keyword.modifier",           { fg = magenta })
  hi("@keyword.repeat",             { fg = magenta })
  hi("@keyword.return",             { fg = magenta })
  hi("@keyword.debug",              { fg = red })
  hi("@keyword.exception",          { fg = red })
  hi("@keyword.conditional",        { fg = magenta })
  hi("@keyword.conditional.ternary", { fg = magenta })
  hi("@keyword.directive",          { fg = br_magenta })
  hi("@keyword.directive.define",   { fg = br_magenta })
  hi("@punctuation.delimiter",      { fg = fg })
  hi("@punctuation.bracket",        { fg = fg })
  hi("@punctuation.special",        { fg = cyan })
  hi("@comment",                    { fg = br_black, italic = true })
  hi("@comment.documentation",      { fg = br_black, italic = true })
  hi("@comment.error",              { fg = red, bold = true })
  hi("@comment.warning",            { fg = yellow, bold = true })
  hi("@comment.todo",               { fg = bg, bg = yellow, bold = true })
  hi("@comment.note",               { fg = blue, bold = true })
  hi("@markup.strong",              { bold = true })
  hi("@markup.italic",              { italic = true })
  hi("@markup.strikethrough",       { strikethrough = true })
  hi("@markup.underline",           { underline = true })
  hi("@markup.heading",             { fg = blue, bold = true })
  hi("@markup.raw",                 { fg = green })
  hi("@markup.link",                { fg = cyan })
  hi("@markup.link.url",            { fg = blue, underline = true })
  hi("@markup.link.label",          { fg = magenta })
  hi("@markup.list",                { fg = magenta })
  hi("@markup.math",                { fg = cyan })
  hi("@tag",                        { fg = red })
  hi("@tag.attribute",              { fg = yellow })
  hi("@tag.delimiter",              { fg = br_black })

  -- ── LSP semantic tokens ──

  hi("@lsp.type.class",         { link = "@type" })
  hi("@lsp.type.decorator",     { link = "@attribute" })
  hi("@lsp.type.enum",          { link = "@type" })
  hi("@lsp.type.enumMember",    { link = "@constant" })
  hi("@lsp.type.function",      { link = "@function" })
  hi("@lsp.type.interface",     { link = "@type" })
  hi("@lsp.type.macro",         { link = "@function.macro" })
  hi("@lsp.type.method",        { link = "@function.method" })
  hi("@lsp.type.namespace",     { link = "@module" })
  hi("@lsp.type.parameter",     { link = "@variable.parameter" })
  hi("@lsp.type.property",      { link = "@property" })
  hi("@lsp.type.struct",        { link = "@type" })
  hi("@lsp.type.type",          { link = "@type" })
  hi("@lsp.type.typeParameter", { link = "@type" })
  hi("@lsp.type.variable",      { link = "@variable" })

  -- ── Git signs ──

  hi("GitSignsAdd",    { fg = green })
  hi("GitSignsChange", { fg = yellow })
  hi("GitSignsDelete", { fg = red })

  -- ── Indent guides ──

  hi("IndentBlanklineChar", { fg = dim2 })
  hi("IblIndent",           { fg = dim2 })
  hi("IblScope",            { fg = br_black })

  -- ── Terminal colors (for :terminal) ──

  vim.g.terminal_color_0  = black
  vim.g.terminal_color_1  = red
  vim.g.terminal_color_2  = green
  vim.g.terminal_color_3  = yellow
  vim.g.terminal_color_4  = blue
  vim.g.terminal_color_5  = magenta
  vim.g.terminal_color_6  = cyan
  vim.g.terminal_color_7  = white
  vim.g.terminal_color_8  = br_black
  vim.g.terminal_color_9  = br_red
  vim.g.terminal_color_10 = br_green
  vim.g.terminal_color_11 = br_yellow
  vim.g.terminal_color_12 = br_blue
  vim.g.terminal_color_13 = br_magenta
  vim.g.terminal_color_14 = br_cyan
  vim.g.terminal_color_15 = br_white
end

-- ── main ────────────────────────────────────────────────────────────────

local _last_theme = nil

local function load()
  local name = get_theme_name()
  if not name then
    vim.notify("ghostty: no theme found in ghostty config", vim.log.levels.WARN)
    return false
  end

  local colors = parse_theme(name)
  if not colors then
    vim.notify("ghostty: could not parse theme '" .. name .. "'", vim.log.levels.WARN)
    return false
  end

  vim.g.colors_name = "ghostty"
  _last_theme = name
  apply(colors)
  return true
end

-- initial load
if not load() then
  vim.cmd("colorscheme default")
end

-- auto-reload on focus (only if theme actually changed)
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("GhosttyThemeSync", { clear = true }),
  callback = function()
    local current = get_theme_name()
    if current and current ~= _last_theme then
      load()
    end
  end,
})

-- manual reload command
vim.api.nvim_create_user_command("GhosttyReload", function()
  if load() then
    vim.notify("ghostty: reloaded theme '" .. _last_theme .. "'")
  end
end, { desc = "Reload colorscheme from Ghostty theme" })
