local M = {}
local colors = require("themes.nord-custom.colors")

-- Theme configuration options
M.options = {
  transparent = true,
  terminal_colors = true,
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    keywords = false,
    functions = false,
    variables = false,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true,
  contrast = "",
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
}

-- Load highlight groups
local function load_highlights()
  local highlights = {}
  
  -- Base editor highlights
  highlights.Normal = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.NormalFloat = { fg = colors.fg, bg = colors.bg_dark }
  highlights.NormalNC = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.Comment = { fg = colors.comment, italic = M.options.italic.comments }
  highlights.Constant = { fg = colors.orange }
  highlights.String = { fg = colors.green, italic = M.options.italic.strings }
  highlights.Character = { fg = colors.green }
  highlights.Number = { fg = colors.purple }
  highlights.Boolean = { fg = colors.purple }
  highlights.Float = { fg = colors.purple }
  highlights.Identifier = { fg = colors.red }
  highlights.Function = { fg = colors.blue, italic = M.options.italic.functions }
  highlights.Statement = { fg = colors.purple }
  highlights.Conditional = { fg = colors.purple }
  highlights.Repeat = { fg = colors.purple }
  highlights.Label = { fg = colors.purple }
  highlights.Operator = { fg = colors.cyan }
  highlights.Keyword = { fg = colors.purple, italic = M.options.italic.keywords }
  highlights.Exception = { fg = colors.purple }
  highlights.PreProc = { fg = colors.yellow }
  highlights.Include = { fg = colors.purple }
  highlights.Define = { fg = colors.purple }
  highlights.Title = { fg = colors.cyan }
  highlights.Macro = { fg = colors.purple }
  highlights.PreCondit = { fg = colors.yellow }
  highlights.Type = { fg = colors.yellow }
  highlights.StorageClass = { fg = colors.yellow }
  highlights.Structure = { fg = colors.yellow }
  highlights.Typedef = { fg = colors.yellow }
  highlights.Special = { fg = colors.cyan }
  highlights.SpecialComment = { fg = colors.comment }
  highlights.Error = { fg = colors.error }
  highlights.Todo = { fg = colors.yellow, bold = true }
  highlights.Underlined = { fg = colors.cyan, underline = true }
  highlights.Cursor = { fg = colors.bg, bg = colors.fg }
  highlights.ColorColumn = { bg = colors.bg_dark }
  highlights.CursorColumn = { bg = colors.bg_dark }
  highlights.CursorLine = { bg = colors.bg_highlight }
  highlights.NonText = { fg = colors.dark3 }
  highlights.Visual = { bg = colors.bg_highlight }
  highlights.VisualNOS = { bg = colors.bg_highlight }
  highlights.Search = { fg = colors.bg, bg = colors.yellow }
  highlights.IncSearch = { fg = colors.bg, bg = colors.orange }
  highlights.CurSearch = { fg = colors.bg, bg = colors.orange }
  highlights.Question = { fg = colors.yellow }
  highlights.StatusLine = { fg = colors.fg, bg = colors.bg_dark }
  highlights.StatusLineNC = { fg = colors.fg_dark, bg = colors.bg_dark }
  highlights.VertSplit = { fg = colors.bg_dark }
  highlights.WinSeparator = { fg = colors.bg_dark }
  highlights.Title = { fg = colors.cyan }
  highlights.LineNr = { fg = colors.fg_gutter }
  highlights.CursorLineNr = { fg = colors.fg }
  highlights.Helpfile = { fg = colors.fg }
  highlights.HelpCommand = { fg = colors.yellow }
  highlights.SpecialKey = { fg = colors.dark3 }
  highlights.Pmenu = { fg = colors.fg, bg = colors.bg_dark }
  highlights.PmenuSel = { fg = colors.bg, bg = colors.blue }
  highlights.PmenuSbar = { bg = colors.bg_dark }
  highlights.PmenuThumb = { bg = colors.fg_gutter }
  highlights.TabLine = { fg = colors.fg_dark, bg = colors.bg_dark }
  highlights.TabLineSel = { fg = colors.fg, bg = colors.bg }
  highlights.TabLineFill = { fg = colors.fg_dark, bg = colors.bg_dark }
  highlights.SpellBad = { undercurl = true, sp = colors.error }
  highlights.SpellCap = { undercurl = true, sp = colors.warning }
  highlights.SpellLocal = { undercurl = true, sp = colors.info }
  highlights.SpellRare = { undercurl = true, sp = colors.hint }
  highlights.ErrorMsg = { fg = colors.error }
  highlights.WarningMsg = { fg = colors.warning }
  highlights.ModeMsg = { fg = colors.fg, bold = true }
  highlights.MoreMsg = { fg = colors.fg, bold = true }
  highlights.Directory = { fg = colors.blue }
  highlights.Folded = { fg = colors.comment, bg = colors.bg_dark }
  highlights.FoldColumn = { fg = colors.comment }
  highlights.SignColumn = { fg = colors.fg_gutter, bg = M.options.transparent and colors.none or colors.bg }
  highlights.Conceal = { fg = colors.dark5 }
  
  -- Diff
  highlights.DiffAdd = { bg = colors.git.add, fg = colors.bg }
  highlights.DiffChange = { bg = colors.git.change, fg = colors.bg }
  highlights.DiffDelete = { bg = colors.git.delete, fg = colors.bg }
  highlights.DiffText = { bg = colors.info, fg = colors.bg }
  highlights.diffAdded = { fg = colors.git.add }
  highlights.diffRemoved = { fg = colors.git.delete }
  highlights.diffChanged = { fg = colors.git.change }
  highlights.diffOldFile = { fg = colors.git.delete }
  highlights.diffNewFile = { fg = colors.git.add }
  highlights.diffFile = { fg = colors.blue }
  highlights.diffLine = { fg = colors.comment }
  highlights.diffIndexLine = { fg = colors.comment }
  
  return highlights
end

-- Load plugin-specific highlights
local function load_plugin_highlights()
  local highlights = {}
  
  -- Legacy syntax highlighting (fallback for when treesitter is not available)
  highlights.Identifier = { fg = colors.fg }
  highlights.Function = { fg = colors.blue }
  highlights.Statement = { fg = colors.blue }
  highlights.Keyword = { fg = colors.blue }
  highlights.Type = { fg = colors.cyan }
  highlights.Constant = { fg = colors.fg }
  highlights.String = { fg = colors.green }
  highlights.Number = { fg = colors.fg }
  highlights.Boolean = { fg = colors.blue }
  highlights.Float = { fg = colors.fg }
  highlights.Comment = { fg = colors.comment, italic = M.options.italic.comments }
  highlights.Special = { fg = colors.cyan }
  highlights.PreProc = { fg = colors.blue }
  highlights.Error = { fg = colors.error }
  highlights.Todo = { fg = colors.green, bold = true }
  
  -- Treesitter
  highlights["@variable"] = { fg = colors.fg, italic = M.options.italic.variables }
  highlights["@variable.builtin"] = { fg = colors.blue }
  highlights["@variable.parameter"] = { fg = colors.fg }
  highlights["@variable.member"] = { fg = colors.fg }
  highlights["@constant"] = { fg = colors.fg }
  highlights["@constant.builtin"] = { fg = colors.blue }
  highlights["@constant.macro"] = { fg = colors.blue }
  highlights["@module"] = { fg = colors.cyan }
  highlights["@module.builtin"] = { fg = colors.blue }
  highlights["@label"] = { fg = colors.blue }
  highlights["@string"] = { fg = colors.green, italic = M.options.italic.strings }
  highlights["@string.documentation"] = { fg = colors.comment }
  highlights["@string.regexp"] = { fg = colors.green }
  highlights["@string.escape"] = { fg = colors.cyan }
  highlights["@string.special"] = { fg = colors.cyan }
  highlights["@string.special.symbol"] = { fg = colors.fg }
  highlights["@string.special.url"] = { fg = colors.blue }
  highlights["@character"] = { fg = colors.green }
  highlights["@character.special"] = { fg = colors.cyan }
  highlights["@boolean"] = { fg = colors.blue }
  highlights["@number"] = { fg = colors.fg }
  highlights["@number.float"] = { fg = colors.fg }
  highlights["@type"] = { fg = colors.cyan }
  highlights["@type.builtin"] = { fg = colors.cyan }
  highlights["@type.definition"] = { fg = colors.cyan }
  highlights["@attribute"] = { fg = colors.blue }
  highlights["@property"] = { fg = colors.fg }
  highlights["@function"] = { fg = colors.blue, italic = M.options.italic.functions }
  highlights["@function.builtin"] = { fg = colors.blue }
  highlights["@function.call"] = { fg = colors.blue }
  highlights["@function.macro"] = { fg = colors.blue }
  highlights["@function.method"] = { fg = colors.blue }
  highlights["@function.method.call"] = { fg = colors.blue }
  highlights["@constructor"] = { fg = colors.blue }
  highlights["@operator"] = { fg = colors.fg }
  highlights["@keyword"] = { fg = colors.blue, italic = M.options.italic.keywords }
  highlights["@keyword.function"] = { fg = colors.blue, italic = M.options.italic.keywords }
  highlights["@keyword.operator"] = { fg = colors.blue }
  highlights["@keyword.import"] = { fg = colors.blue }
  highlights["@keyword.storage"] = { fg = colors.blue }
  highlights["@keyword.repeat"] = { fg = colors.blue }
  highlights["@keyword.return"] = { fg = colors.blue }
  highlights["@keyword.debug"] = { fg = colors.blue }
  highlights["@keyword.exception"] = { fg = colors.blue }
  highlights["@keyword.conditional"] = { fg = colors.blue }
  highlights["@keyword.conditional.ternary"] = { fg = colors.blue }
  highlights["@keyword.directive"] = { fg = colors.blue }
  highlights["@keyword.directive.define"] = { fg = colors.blue }
  highlights["@punctuation.delimiter"] = { fg = colors.fg }
  highlights["@punctuation.bracket"] = { fg = colors.fg }
  highlights["@punctuation.special"] = { fg = colors.fg }
  highlights["@comment"] = { fg = colors.comment, italic = M.options.italic.comments }
  highlights["@comment.documentation"] = { fg = colors.comment }
  highlights["@comment.error"] = { fg = colors.error }
  highlights["@comment.warning"] = { fg = colors.warning }
  highlights["@comment.todo"] = { fg = colors.yellow }
  highlights["@comment.note"] = { fg = colors.info }
  highlights["@markup.strong"] = { bold = true }
  highlights["@markup.emphasis"] = { italic = true }
  highlights["@markup.underline"] = { underline = true }
  highlights["@markup.strike"] = { strikethrough = true }
  highlights["@markup.title"] = { fg = colors.blue, bold = true }
  highlights["@markup.literal"] = { fg = colors.blue2 }
  highlights["@markup.uri"] = { fg = colors.cyan, underline = true }
  highlights["@markup.math"] = { fg = colors.blue }
  highlights["@markup.environment"] = { fg = colors.magenta }
  highlights["@markup.environment.name"] = { fg = colors.yellow }
  highlights["@markup.reference"] = { fg = colors.magenta2 }
  highlights["@markup.raw"] = { fg = colors.cyan }
  highlights["@markup.raw.block"] = { fg = colors.cyan }
  highlights["@markup.link"] = { fg = colors.orange }
  highlights["@markup.link.label"] = { fg = colors.blue }
  highlights["@markup.link.url"] = { fg = colors.cyan, underline = true }
  highlights["@markup.list"] = { fg = colors.blue5 }
  highlights["@markup.list.checked"] = { fg = colors.green1 }
  highlights["@markup.list.unchecked"] = { fg = colors.blue5 }
  highlights["@diff.plus"] = { fg = colors.git.add }
  highlights["@diff.minus"] = { fg = colors.git.delete }
  highlights["@diff.delta"] = { fg = colors.git.change }
  highlights["@tag"] = { fg = colors.cyan }
  highlights["@tag.attribute"] = { fg = colors.cyan }
  highlights["@tag.delimiter"] = { fg = colors.fg }
  
  -- LSP
  highlights.LspReferenceText = { bg = colors.fg_gutter }
  highlights.LspReferenceRead = { bg = colors.fg_gutter }
  highlights.LspReferenceWrite = { bg = colors.fg_gutter }
  highlights.LspCodeLens = { fg = colors.comment }
  highlights.LspCodeLensSeparator = { fg = colors.fg_gutter }
  highlights.LspSignatureActiveParameter = { bg = colors.bg_highlight, bold = true }
  
  -- Diagnostics
  highlights.DiagnosticError = { fg = colors.error }
  highlights.DiagnosticWarn = { fg = colors.warning }
  highlights.DiagnosticInfo = { fg = colors.info }
  highlights.DiagnosticHint = { fg = colors.hint }
  highlights.DiagnosticVirtualTextError = { fg = colors.error, bg = colors.none }
  highlights.DiagnosticVirtualTextWarn = { fg = colors.warning, bg = colors.none }
  highlights.DiagnosticVirtualTextInfo = { fg = colors.info, bg = colors.none }
  highlights.DiagnosticVirtualTextHint = { fg = colors.hint, bg = colors.none }
  highlights.DiagnosticUnderlineError = { undercurl = true, sp = colors.error }
  highlights.DiagnosticUnderlineWarn = { undercurl = true, sp = colors.warning }
  highlights.DiagnosticUnderlineInfo = { undercurl = true, sp = colors.info }
  highlights.DiagnosticUnderlineHint = { undercurl = true, sp = colors.hint }
  highlights.DiagnosticSignError = { fg = colors.error }
  highlights.DiagnosticSignWarn = { fg = colors.warning }
  highlights.DiagnosticSignInfo = { fg = colors.info }
  highlights.DiagnosticSignHint = { fg = colors.hint }
  
  -- Git Signs
  highlights.GitSignsAdd = { fg = colors.git.add }
  highlights.GitSignsChange = { fg = colors.git.change }
  highlights.GitSignsDelete = { fg = colors.git.delete }
  highlights.GitSignsAddNr = { fg = colors.git.add }
  highlights.GitSignsChangeNr = { fg = colors.git.change }
  highlights.GitSignsDeleteNr = { fg = colors.git.delete }
  highlights.GitSignsAddLn = { bg = colors.git.add, fg = colors.bg }
  highlights.GitSignsChangeLn = { bg = colors.git.change, fg = colors.bg }
  highlights.GitSignsDeleteLn = { bg = colors.git.delete, fg = colors.bg }
  
  -- Telescope
  highlights.TelescopeNormal = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg_dark }
  highlights.TelescopeBorder = { fg = colors.fg_gutter, bg = M.options.transparent and colors.none or colors.bg_dark }
  highlights.TelescopePromptNormal = { fg = colors.fg, bg = colors.bg_highlight }
  highlights.TelescopePromptBorder = { fg = colors.fg_gutter, bg = colors.bg_highlight }
  highlights.TelescopePromptTitle = { fg = colors.bg, bg = colors.cyan }
  highlights.TelescopeResultsTitle = { fg = colors.bg, bg = colors.blue }
  highlights.TelescopePreviewTitle = { fg = colors.bg, bg = colors.green }
  highlights.TelescopeSelection = { bg = colors.bg_highlight }
  highlights.TelescopeSelectionCaret = { fg = colors.cyan }
  highlights.TelescopeMatching = { fg = colors.yellow, bold = true }
  
  -- WhichKey
  highlights.WhichKey = { fg = colors.cyan }
  highlights.WhichKeyGroup = { fg = colors.blue }
  highlights.WhichKeyDesc = { fg = colors.fg }
  highlights.WhichKeySeperator = { fg = colors.comment }
  highlights.WhichKeySeparator = { fg = colors.comment }
  highlights.WhichKeyFloat = { bg = M.options.transparent and colors.none or colors.bg_dark }
  highlights.WhichKeyValue = { fg = colors.comment }
  
  -- NvimTree
  highlights.NvimTreeNormal = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.NvimTreeWinSeparator = { fg = colors.bg_dark, bg = M.options.transparent and colors.none or colors.bg_dark }
  highlights.NvimTreeNormalNC = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.NvimTreeRootFolder = { fg = colors.blue, bold = true }
  highlights.NvimTreeGitDirty = { fg = colors.git.change }
  highlights.NvimTreeGitNew = { fg = colors.git.add }
  highlights.NvimTreeGitDeleted = { fg = colors.git.delete }
  highlights.NvimTreeSpecialFile = { fg = colors.purple, underline = true }
  highlights.NvimTreeIndentMarker = { fg = colors.fg_gutter }
  highlights.NvimTreeImageFile = { fg = colors.fg_dark }
  highlights.NvimTreeSymlink = { fg = colors.cyan }
  highlights.NvimTreeFolderIcon = { bg = colors.none, fg = colors.blue }
  
  -- BufferLine (darker background)
  highlights.BufferLineIndicatorSelected = { fg = colors.cyan }
  highlights.BufferLineFill = { bg = colors.nord1 }
  highlights.BufferLineBackground = { fg = colors.fg_dark, bg = colors.nord1 }
  highlights.BufferLineTab = { fg = colors.fg_dark, bg = colors.nord1 }
  highlights.BufferLineTabSelected = { fg = colors.cyan, bg = colors.bg }
  highlights.BufferLineTabClose = { fg = colors.fg_dark, bg = colors.nord1 }
  highlights.BufferLineBufferSelected = { fg = colors.fg, bg = colors.bg, bold = true }
  highlights.BufferLineBufferVisible = { fg = colors.fg, bg = colors.nord1 }
  highlights.BufferLineCloseButton = { fg = colors.fg_dark, bg = colors.nord1 }
  highlights.BufferLineCloseButtonSelected = { fg = colors.red, bg = colors.bg }
  highlights.BufferLineCloseButtonVisible = { fg = colors.fg_dark, bg = colors.nord1 }
  highlights.BufferLineModified = { fg = colors.warning, bg = colors.nord1 }
  highlights.BufferLineModifiedSelected = { fg = colors.warning, bg = colors.bg }
  highlights.BufferLineModifiedVisible = { fg = colors.warning, bg = colors.nord1 }
  highlights.BufferLineDuplicate = { fg = colors.fg_dark, bg = colors.nord1 }
  highlights.BufferLineDuplicateSelected = { fg = colors.fg, bg = colors.bg }
  highlights.BufferLineDuplicateVisible = { fg = colors.fg, bg = colors.nord1 }
  highlights.BufferLineSeparator = { fg = colors.nord1, bg = colors.nord1 }
  highlights.BufferLineSeparatorSelected = { fg = colors.nord1, bg = colors.nord1 }
  highlights.BufferLineSeparatorVisible = { fg = colors.nord1, bg = colors.nord1 }
  
  -- BufferLine file icons (ensure consistent background)
  highlights.BufferLineDevIconLua = { bg = colors.nord1 }
  highlights.BufferLineDevIconLuaSelected = { bg = colors.bg }
  highlights.BufferLineDevIconJs = { bg = colors.nord1 }
  highlights.BufferLineDevIconJsSelected = { bg = colors.bg }
  highlights.BufferLineDevIconTs = { bg = colors.nord1 }
  highlights.BufferLineDevIconTsSelected = { bg = colors.bg }
  highlights.BufferLineDevIconTsx = { bg = colors.nord1 }
  highlights.BufferLineDevIconTsxSelected = { bg = colors.bg }
  highlights.BufferLineDevIconJsx = { bg = colors.nord1 }
  highlights.BufferLineDevIconJsxSelected = { bg = colors.bg }
  highlights.BufferLineDevIconVue = { bg = colors.nord1 }
  highlights.BufferLineDevIconVueSelected = { bg = colors.bg }
  highlights.BufferLineDevIconPy = { bg = colors.nord1 }
  highlights.BufferLineDevIconPySelected = { bg = colors.bg }
  highlights.BufferLineDevIconGo = { bg = colors.nord1 }
  highlights.BufferLineDevIconGoSelected = { bg = colors.bg }
  highlights.BufferLineDevIconRust = { bg = colors.nord1 }
  highlights.BufferLineDevIconRustSelected = { bg = colors.bg }
  highlights.BufferLineDevIconDefault = { bg = colors.nord1 }
  highlights.BufferLineDevIconDefaultSelected = { bg = colors.bg }
  
  -- Lualine
  highlights.lualine_a_normal = { fg = colors.bg, bg = colors.blue, bold = true }
  highlights.lualine_a_insert = { fg = colors.bg, bg = colors.green, bold = true }
  highlights.lualine_a_visual = { fg = colors.bg, bg = colors.purple, bold = true }
  highlights.lualine_a_replace = { fg = colors.bg, bg = colors.red, bold = true }
  highlights.lualine_a_command = { fg = colors.bg, bg = colors.yellow, bold = true }
  highlights.lualine_b_normal = { fg = colors.fg, bg = colors.bg_highlight }
  highlights.lualine_c_normal = { fg = colors.fg_dark, bg = colors.bg_dark }
  
  -- Noice
  highlights.NoicePopup = { bg = colors.bg_dark }
  highlights.NoicePopupBorder = { fg = colors.blue, bg = colors.bg_dark }
  highlights.NoiceCompletionItemKindDefault = { fg = colors.fg_dark, bg = colors.none }
  highlights.NoiceCmdlinePopup = { bg = colors.bg_dark }
  highlights.NoiceCmdlinePopupBorder = { fg = colors.blue, bg = colors.bg_dark }
  highlights.NoiceCmdlinePopupTitle = { fg = colors.blue, bg = colors.bg_dark }
  highlights.NoiceCmdlineIcon = { fg = colors.cyan }
  highlights.NoiceConfirm = { bg = colors.bg_dark }
  highlights.NoiceConfirmBorder = { fg = colors.blue, bg = colors.bg_dark }
  
  -- Dashboard
  highlights.DashboardShortCut = { fg = colors.cyan }
  highlights.DashboardHeader = { fg = colors.blue }
  highlights.DashboardCenter = { fg = colors.purple }
  highlights.DashboardFooter = { fg = colors.yellow, italic = true }
  highlights.DashboardKey = { fg = colors.orange }
  highlights.DashboardDesc = { fg = colors.cyan }
  highlights.DashboardIcon = { fg = colors.cyan, bold = true }
  
  -- Alpha (alternative dashboard)
  highlights.AlphaShortcut = { fg = colors.orange }
  highlights.AlphaHeader = { fg = colors.blue }
  highlights.AlphaHeaderLabel = { fg = colors.orange }
  highlights.AlphaFooter = { fg = colors.blue2, italic = true }
  highlights.AlphaButtons = { fg = colors.cyan }
  
  -- Avante (AI coding assistant)
  highlights.AvanteTitle = { fg = colors.blue, bold = true }
  highlights.AvanteReversedTitle = { fg = colors.bg, bg = colors.blue }
  highlights.AvanteSubtitle = { fg = colors.fg_dark }
  highlights.AvanteReversedSubtitle = { fg = colors.bg, bg = colors.fg_dark }
  highlights.AvanteThirdTitle = { fg = colors.cyan }
  highlights.AvanteReversedThirdTitle = { fg = colors.bg, bg = colors.cyan }
  highlights.AvanteBorder = { fg = colors.fg_gutter }
  highlights.AvanteNormal = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteInsert = { bg = colors.blue, fg = colors.bg }
  highlights.AvanteConflictCurrent = { fg = colors.git.change, bg = colors.bg_highlight }
  highlights.AvanteConflictIncoming = { fg = colors.git.add, bg = colors.bg_highlight }
  highlights.AvanteConflictCurrentLabel = { fg = colors.git.change, bold = true }
  highlights.AvanteConflictIncomingLabel = { fg = colors.git.add, bold = true }
  highlights.AvantePopupHint = { fg = colors.hint }
  highlights.AvanteInlineHint = { fg = colors.hint, italic = true }
  highlights.AvanteCodeBlock = { bg = colors.bg_highlight }
  highlights.AvanteSeparator = { fg = colors.fg_gutter }
  highlights.AvanteVerticalSeparator = { fg = colors.fg_gutter }
  highlights.AvanteHorizontalSeparator = { fg = colors.fg_gutter }
  highlights.AvanteWinSeparator = { fg = colors.fg_gutter }
  highlights.AvanteSidebarWinSeparator = { fg = colors.fg_gutter }
  
  -- Additional Avante highlights for consistent backgrounds
  highlights.AvanteMessage = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteStatus = { fg = colors.green, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteStatusCompleted = { fg = colors.green, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteTaskCompleted = { fg = colors.green, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteTask = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteChat = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteChatBackground = { bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteFloatBackground = { bg = M.options.transparent and colors.none or colors.bg }
  
  -- Additional Avante window and sidebar highlights
  highlights.AvanteSidebar = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteSidebarTitle = { fg = colors.blue, bg = M.options.transparent and colors.none or colors.bg, bold = true }
  highlights.AvantePrompt = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.AvanteInput = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  
  -- Markdown and render-markdown
  highlights.RenderMarkdownH1 = { fg = colors.blue, bold = true }
  highlights.RenderMarkdownH2 = { fg = colors.cyan, bold = true }
  highlights.RenderMarkdownH3 = { fg = colors.green, bold = true }
  highlights.RenderMarkdownH4 = { fg = colors.yellow, bold = true }
  highlights.RenderMarkdownH5 = { fg = colors.orange, bold = true }
  highlights.RenderMarkdownH6 = { fg = colors.purple, bold = true }
  highlights.RenderMarkdownCode = { fg = colors.cyan, bg = colors.bg_highlight }
  highlights.RenderMarkdownCodeInline = { fg = colors.cyan, bg = colors.bg_highlight }
  highlights.RenderMarkdownBullet = { fg = colors.blue }
  highlights.RenderMarkdownTableHead = { fg = colors.purple, bold = true }
  highlights.RenderMarkdownTableRow = { fg = colors.fg }
  highlights.RenderMarkdownSuccess = { fg = colors.green }
  highlights.RenderMarkdownInfo = { fg = colors.info }
  highlights.RenderMarkdownHint = { fg = colors.hint }
  highlights.RenderMarkdownWarn = { fg = colors.warning }
  highlights.RenderMarkdownError = { fg = colors.error }
  highlights.RenderMarkdownQuote = { fg = colors.comment, italic = true }
  highlights.RenderMarkdownLink = { fg = colors.cyan, underline = true }
  
  -- Flutter Tools
  highlights.FlutterToolsOutlineIndentGuides = { fg = colors.fg_gutter }
  
  -- Lazy.nvim
  highlights.LazyProgressTodo = { fg = colors.fg_gutter }
  highlights.LazyProgressDone = { fg = colors.green }
  highlights.LazyCommit = { fg = colors.yellow }
  highlights.LazyCommitIssue = { fg = colors.purple }
  highlights.LazyCommitType = { fg = colors.blue }
  highlights.LazyCommitScope = { fg = colors.cyan }
  highlights.LazyLogTime = { fg = colors.fg_gutter }
  highlights.LazyBackdrop = { bg = colors.bg_dark }
  highlights.LazyButton = { bg = colors.bg_highlight, fg = colors.fg }
  highlights.LazyButtonActive = { bg = colors.blue, fg = colors.bg, bold = true }
  highlights.LazyComment = { fg = colors.comment }
  highlights.LazyCommitScope = { fg = colors.cyan }
  highlights.LazyDimmed = { fg = colors.fg_gutter }
  highlights.LazyDir = { fg = colors.blue }
  highlights.LazyH1 = { bg = colors.blue, fg = colors.bg, bold = true }
  highlights.LazyH2 = { fg = colors.blue, bold = true }
  highlights.LazyLocal = { fg = colors.cyan }
  highlights.LazyNoCond = { fg = colors.fg_gutter }
  highlights.LazyNormal = { fg = colors.fg, bg = colors.bg_dark }
  highlights.LazyProgressTodo = { fg = colors.fg_gutter }
  highlights.LazyProp = { fg = colors.purple }
  highlights.LazyReasonCmd = { fg = colors.yellow }
  highlights.LazyReasonEvent = { fg = colors.purple }
  highlights.LazyReasonFt = { fg = colors.cyan }
  highlights.LazyReasonImport = { fg = colors.fg }
  highlights.LazyReasonKeys = { fg = colors.green }
  highlights.LazyReasonPlugin = { fg = colors.orange }
  highlights.LazyReasonRequire = { fg = colors.blue }
  highlights.LazyReasonRuntime = { fg = colors.purple }
  highlights.LazyReasonSource = { fg = colors.cyan }
  highlights.LazyReasonStart = { fg = colors.fg }
  highlights.LazySpecial = { fg = colors.blue }
  highlights.LazyTaskError = { fg = colors.error }
  highlights.LazyTaskOutput = { fg = colors.fg }
  highlights.LazyUrl = { fg = colors.cyan }
  highlights.LazyValue = { fg = colors.cyan }
  
  -- Completion (nvim-cmp)
  highlights.CmpItemAbbr = { fg = colors.fg }
  highlights.CmpItemAbbrDeprecated = { fg = colors.fg_gutter, strikethrough = true }
  highlights.CmpItemAbbrMatch = { fg = colors.blue, bold = true }
  highlights.CmpItemAbbrMatchFuzzy = { fg = colors.blue, bold = true }
  highlights.CmpItemMenu = { fg = colors.comment }
  highlights.CmpItemKind = { fg = colors.purple }
  highlights.CmpItemKindText = { fg = colors.green }
  highlights.CmpItemKindMethod = { fg = colors.blue }
  highlights.CmpItemKindFunction = { fg = colors.blue }
  highlights.CmpItemKindConstructor = { fg = colors.purple }
  highlights.CmpItemKindField = { fg = colors.blue }
  highlights.CmpItemKindClass = { fg = colors.yellow }
  highlights.CmpItemKindInterface = { fg = colors.yellow }
  highlights.CmpItemKindModule = { fg = colors.cyan }
  highlights.CmpItemKindProperty = { fg = colors.blue }
  highlights.CmpItemKindValue = { fg = colors.orange }
  highlights.CmpItemKindEnum = { fg = colors.yellow }
  highlights.CmpItemKindKeyword = { fg = colors.purple }
  highlights.CmpItemKindSnippet = { fg = colors.green }
  highlights.CmpItemKindFile = { fg = colors.blue }
  highlights.CmpItemKindFolder = { fg = colors.blue }
  highlights.CmpItemKindColor = { fg = colors.red }
  highlights.CmpItemKindReference = { fg = colors.red }
  highlights.CmpItemKindConstant = { fg = colors.orange }
  highlights.CmpItemKindStruct = { fg = colors.yellow }
  highlights.CmpItemKindVariable = { fg = colors.red }
  highlights.CmpItemKindTypeParameter = { fg = colors.yellow }
  
  -- Fidget (LSP progress)
  highlights.FidgetTask = { fg = colors.comment }
  highlights.FidgetTitle = { fg = colors.cyan }
  
  -- Gitsigns  
  highlights.GitSignsCurrentLineBlame = { fg = colors.comment, italic = true }
  
  -- Mason
  highlights.MasonNormal = { fg = colors.fg, bg = colors.bg_dark }
  highlights.MasonHighlight = { fg = colors.blue }
  highlights.MasonHighlightBlock = { fg = colors.bg, bg = colors.blue }
  highlights.MasonHighlightBlockBold = { fg = colors.bg, bg = colors.blue, bold = true }
  highlights.MasonHeader = { fg = colors.bg, bg = colors.blue, bold = true }
  highlights.MasonHeaderSecondary = { fg = colors.bg, bg = colors.cyan, bold = true }
  highlights.MasonMuted = { fg = colors.comment }
  highlights.MasonMutedBlock = { fg = colors.comment, bg = colors.bg_highlight }
  
  -- Notify
  highlights.NotifyBackground = { bg = colors.bg }
  highlights.NotifyERRORBorder = { fg = colors.error }
  highlights.NotifyWARNBorder = { fg = colors.warning }
  highlights.NotifyINFOBorder = { fg = colors.info }
  highlights.NotifyDEBUGBorder = { fg = colors.comment }
  highlights.NotifyTRACEBorder = { fg = colors.purple }
  highlights.NotifyERRORIcon = { fg = colors.error }
  highlights.NotifyWARNIcon = { fg = colors.warning }
  highlights.NotifyINFOIcon = { fg = colors.info }
  highlights.NotifyDEBUGIcon = { fg = colors.comment }
  highlights.NotifyTRACEIcon = { fg = colors.purple }
  highlights.NotifyERRORTitle = { fg = colors.error }
  highlights.NotifyWARNTitle = { fg = colors.warning }
  highlights.NotifyINFOTitle = { fg = colors.info }
  highlights.NotifyDEBUGTitle = { fg = colors.comment }
  highlights.NotifyTRACETitle = { fg = colors.purple }
  
  -- Neo-tree
  highlights.NeoTreeNormal = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.NeoTreeNormalNC = { fg = colors.fg, bg = M.options.transparent and colors.none or colors.bg }
  highlights.NeoTreeWinSeparator = { fg = colors.bg_dark, bg = M.options.transparent and colors.none or colors.bg_dark }
  
  -- Terminal
  highlights.TerminalNormal = { fg = colors.fg, bg = colors.bg }
  highlights.TerminalNormalNC = { fg = colors.fg, bg = colors.bg }
  
  return highlights
end

-- Set terminal colors
local function set_terminal_colors()
  if not M.options.terminal_colors then
    return
  end
  
  vim.g.terminal_color_0 = colors.terminal_black
  vim.g.terminal_color_1 = colors.red
  vim.g.terminal_color_2 = colors.green
  vim.g.terminal_color_3 = colors.yellow
  vim.g.terminal_color_4 = colors.blue
  vim.g.terminal_color_5 = colors.purple
  vim.g.terminal_color_6 = colors.cyan
  vim.g.terminal_color_7 = colors.fg
  vim.g.terminal_color_8 = colors.fg_gutter
  vim.g.terminal_color_9 = colors.red
  vim.g.terminal_color_10 = colors.green
  vim.g.terminal_color_11 = colors.yellow
  vim.g.terminal_color_12 = colors.blue
  vim.g.terminal_color_13 = colors.purple
  vim.g.terminal_color_14 = colors.cyan
  vim.g.terminal_color_15 = colors.fg
  vim.g.terminal_color_background = colors.bg
  vim.g.terminal_color_foreground = colors.fg
end

-- Setup transparency for specific windows
local function setup_transparency()
  if not M.options.transparent then
    return
  end
  
  -- Set up autocmds for selective transparency
  vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    callback = function()
      local buf_name = vim.api.nvim_buf_get_name(0)
      local filetype = vim.bo.filetype
      local buftype = vim.bo.buftype
      
      -- Transparent windows
      local transparent_types = {
        "NvimTree",
        "neo-tree",
        "Telescope",
        "WhichKey",
        "alpha",
        "dashboard",
        "Avante",
        "AvanteInput"
      }
      
      -- Solid windows  
      local solid_types = {
        "terminal",
        "toggleterm"
      }
      
      -- Check if should be transparent
      local should_be_transparent = false
      for _, type_name in ipairs(transparent_types) do
        if filetype == type_name or buf_name:match(type_name) or buftype == type_name then
          should_be_transparent = true
          break
        end
      end
      
      -- Check if should be solid
      local should_be_solid = false
      for _, type_name in ipairs(solid_types) do
        if filetype == type_name or buf_name:match(type_name) or buftype == type_name then
          should_be_solid = true
          break
        end
      end
      
      if should_be_transparent then
        vim.wo.winblend = 15
      elseif should_be_solid then
        vim.wo.winblend = 0
      else
        -- Default editor windows
        vim.wo.winblend = 0
      end
    end
  })
end

-- Main setup function
function M.setup(options)
  M.options = vim.tbl_deep_extend("force", M.options, options or {})
  
  -- Reset highlights
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  
  vim.o.termguicolors = true
  vim.g.colors_name = "nord-custom"
  
  -- Load highlights
  local highlights = load_highlights()
  local plugin_highlights = load_plugin_highlights()
  
  -- Merge and apply highlights
  local all_highlights = vim.tbl_extend("force", highlights, plugin_highlights)
  for group, highlight in pairs(all_highlights) do
    vim.api.nvim_set_hl(0, group, highlight)
  end
  
  -- Set terminal colors
  set_terminal_colors()
  
  -- Setup transparency
  setup_transparency()
  
  -- Apply user overrides
  for group, highlight in pairs(M.options.overrides) do
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

return M