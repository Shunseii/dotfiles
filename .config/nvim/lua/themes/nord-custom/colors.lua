-- Nord Color Palette
-- https://www.nordtheme.com/

local M = {}

-- Polar Night (Dark Colors)
M.nord0 = "#2e3440"  -- darkest
M.nord1 = "#3b4252"  -- dark
M.nord2 = "#434c5e"  -- medium dark
M.nord3 = "#4c566a"  -- light dark

-- Snow Storm (Light Colors)
M.nord4 = "#d8dee9"  -- dark white
M.nord5 = "#e5e9f0"  -- medium white
M.nord6 = "#eceff4"  -- light white

-- Frost (Blue Colors)
M.nord7 = "#8fbcbb"  -- light blue
M.nord8 = "#88c0d0"  -- medium blue
M.nord9 = "#81a1c1"  -- dark blue
M.nord10 = "#5e81ac" -- darkest blue

-- Aurora (Accent Colors)
M.nord11 = "#bf616a" -- red
M.nord12 = "#d08770" -- orange
M.nord13 = "#ebcb8b" -- yellow
M.nord14 = "#a3be8c" -- green
M.nord15 = "#b48ead" -- purple

-- Extended palette for better plugin support
M.bg = M.nord0
M.bg_dark = M.nord1
M.bg_highlight = M.nord2
M.terminal_black = M.nord1
M.fg = M.nord4
M.fg_dark = M.nord3
M.fg_gutter = M.nord3
M.dark3 = M.nord2
M.comment = M.nord3
M.dark5 = M.nord3
M.blue0 = M.nord8
M.blue = M.nord9
M.cyan = M.nord8
M.blue1 = M.nord10
M.blue2 = M.nord7
M.blue5 = M.nord10
M.blue6 = M.nord7
M.blue7 = M.nord8
M.purple = M.nord15
M.magenta = M.nord15
M.magenta2 = M.nord15
M.red = M.nord11
M.red1 = M.nord11
M.orange = M.nord12
M.yellow = M.nord13
M.green = M.nord14
M.green1 = M.nord14
M.green2 = M.nord14
M.teal = M.nord7

-- Status and special colors
M.warning = M.nord13
M.error = M.nord11
M.info = M.nord8
M.hint = M.nord10
M.git = {
  add = M.nord14,
  change = M.nord13,
  delete = M.nord11,
  ignore = M.nord3,
}

-- Transparency support
M.none = "NONE"

return M