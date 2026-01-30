local M = {}

M.from_colors = function(c, _)
    local t = c.terminal
    return {
        terminal_color_0  = t.black,
        terminal_color_1  = t.red,
        terminal_color_2  = t.green,
        terminal_color_3  = t.yellow,
        terminal_color_4  = t.blue,
        terminal_color_5  = t.magenta,
        terminal_color_6  = t.cyan,
        terminal_color_7  = t.white,
        terminal_color_8  = t.bright_black,
        terminal_color_9  = t.bright_red,
        terminal_color_10 = t.bright_green,
        terminal_color_11 = t.bright_yellow,
        terminal_color_12 = t.bright_blue,
        terminal_color_13 = t.bright_magenta,
        terminal_color_14 = t.bright_cyan,
        terminal_color_15 = t.bright_white,
    }
end

return M
