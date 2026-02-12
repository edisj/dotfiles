local M = {}

---@param c Colors
M.from_colors = function(c, opts)
    local ed = c.editor
    local diag = c.diagnostic
    local syn = c.syntax

    -- see `:h highlight-groups`
    -- colors that are explicitly handled by me, i.e. no linking
    local highlights = {
        Normal       = { fg = c.fg,            bg = ed.Normal },          -- Normal text.
        NormalNC     = { fg = c.fg,            bg = ed.NormalNC },        -- Normal text in non-current windows.


        NormalFloat  = { fg = c.fg,            bg = ed.NormalFloat },     -- Normal text in floating windows.
        FloatBorder  = { fg = ed.FloatBorder,  bg = ed.NormalFloat },     -- Border of floating windows.
        FloatTitle   = { fg = ed.FloatTitle,   bg = ed.NormalFloat },     -- Title of floating windows.
        FloatFooter  = { fg = ed.FloatFooter,  bg = ed.NormalFloat },     -- Footer of floating windows.

        Cursor       = { fg = c.bg,            bg = c.fg },               -- Character under the cursor.
        Conceal      = { fg = ed.Conceal,      bg = nil },                -- Placeholder characters substituted for concealed text (see 'conceallevel').
        CursorLine   = { fg = nil,             bg = ed.CursorLine },      -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
        Directory    = { fg = ed.Directory,    bg = nil },                -- Directory names (and other special names in listings).
        EndOfBuffer  = { fg = ed.LineNr,            bg = nil },                -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
        Folded       = { fg = ed.Folded,       bg = nil },                -- Line used for closed folds.
        FoldColumn   = { fg = syn.Comment,     bg = c.bg },               -- 'foldcolumn'
        Search       = { fg = nil,             bg = ed.Search },          -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
        IncSearch    = { fg = c.bg,            bg = ed.IncSearch },       -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
        Substitute   = { fg = nil,             bg = ed.Substitute },      -- |:substitute| replacement text highlighting.
        LineNr       = { fg = ed.LineNr,       bg = nil },                -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
        CursorLineNr = { fg = ed.CursorLineNr, bg = ed.CursorLine },      -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "both", for the cursor line.
        MatchParen   = { fg = ed.MatchParen,   bg = ed.Search },          -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
        MsgArea      = { fg = nil,             bg = ed.MsgArea },         -- Area for messages and command-line, see also 'cmdheight'.
        ModeMsg      = { fg = ed.ModeMsg,      bg = nil },                -- 'showmode' message (e.g., "-- INSERT --").
        MoreMsg      = { fg = ed.MoreMsg,      bg = ed.MsgArea },         -- |more-prompt|
        NonText      = { fg = ed.NonText,      bg = nil },                -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text

        Pmenu        = { fg = nil,             bg = ed.Pmenu },           -- Popup menu: Normal item.
        PmenuSel     = { fg = nil,             bg = ed.PmenuSel },        -- Popup menu: Selected item.
        PmenuMatch   = { fg = ed.PmenuMatch,   bg = nil },                -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
        PmenuThumb   = { fg = nil,             bg = ed.PmenuThumb },      -- Popup menu: Thumb of the scrollbar.

        Question     = { fg = ed.Question,     bg = nil},                 -- |hit-enter| prompt and yes/no questions.
        QuickFixLine = { fg = nil,             bg = ed.QuickFixLine },    -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
        SignColumn   = { fg = ed.SignColumn,   bg = ed.NormalFloat },     -- Column where |signs| are displayed.

        StatusLine   = { fg = nil,             bg = ed.StatusLine },      -- Status line of current window.
        -- StatusLine   = { fg = nil,             bg = syn.Function },      -- Status line of current window.
        TabLine      = { fg = nil,             bg = ed.TabLine },         -- Tab pages line, not active tab page label.

        Title        = { fg = ed.Title,        bg = nil },                -- Titles for output from ":set all", ":autocmd" etc.
        Visual       = { fg = nil,             bg = ed.Visual },          -- Visual mode selection.
        WildMenu     = { fg = c.bg,             bg = ed.WildMenu },        -- Current match in 'wildmenu' completion.
        WinSeparator = { fg = ed.WinSeparator, bg = c.none },             -- Separators between window splits.
        WinSeparatorNC = { fg = ed.WinSeparator, bg = c.none },
        WinSeparatorFocused = {fg = ed.WinSeparator, bg = c.none},

        SpellBad     = { sp = diag.error, undercurl = true },             -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
        SpellCap     = { sp = diag.warn,  undercurl = true },             -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
        SpellLocal   = { sp = diag.info,  undercurl = true },             -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
        SpellRare    = { sp = diag.hint,  undercurl = true },             -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
        WhiteSpace   = { fg = ed.WhiteSpace, bg = nil},
    }

    local hl_bg = function(key, fallback)
        return ed[key] and { bg = ed[key] } or { link = fallback }
    end
    for key, fallback in pairs {
        StatusLineNC   = "StatusLine",     -- Status lines of not-current windows.
        StatusLineTerm = "StatusLine",     -- Status line of |terminal| window.
        TabLineFill    = "TabLine",        -- Tab pages line, where there are no labels.
        TabLineSel     = "TabLineSel",     -- Tab pages line, active tab page label.
        WinBar         = "StatusLine" ,    -- Window bar of current window.
        WinBarNC       = "StatusLineNC",   -- Window bar of not-current windows.
        VisualNOS      = "Visual" ,        -- Visual mode selection when vim is "Not Owning the Selection".
        PmenuSbar      = "Pmenu",          -- Popup menu: Scrollbar.
    } do
        highlights[key] = hl_bg(key, fallback)
    end

    local hl_fg = function(key, fallback)
        return ed[key] and { bg = ed[key] } or { link = fallback }
    end
    for key, fallback in pairs {
        healthError   = "DiagnosticError",
        healthSuccess = "DiagnosticOk",
        healthWarning = "DiagnosticWarn",
        WarningMsg    = "DiagnosticWarn",   -- Warning messages.
        SpecialKey    = "Comment",          -- Unprintable characters: Text displayed differently from what it really is. But not 'listchars' whitespace. |hl-Whitespace|
        -- WhiteSpace    = "NonText",          -- "nbsp", "space", "tab", "multispace", "lead" and "trail" in 'listchars'.
    } do
        highlights[key] = hl_fg(key, fallback)
    end

    return highlights
    --     -- see `:h lsp-highlight`
    --     LspReferenceText            = {},     -- used for highlighting "text" references
    --     LspReferenceRead            = {},     -- used for highlighting "read" references
    --     LspReferenceWrite           = {},     -- used for highlighting "write" references
    --     LspReferenceTarget          = {},                       -- used for highlighting reference targets (e.g. in a hover range)
    --     LspInlayHint                = {},                      -- used for highlighting inlay hints
    --
    --     LspSignatureActiveParameter = { bold = true },          -- used to highlight the active parameter in the signature help. See |vim.lsp.handlers.signature_help()|.
    --     LspCodeLens                 = {},       -- used to color the virtual text of the codelens. See |nvim_buf_set_extmark()|.
    --     LspCodeLensSeparator        = {},                       -- used to color the separator between two or more code lenses.
end

return M
