
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄ 

local dpi = require("utils.ui").dpi
local gfs = require("gears.filesystem")
local gears    = require("gears")
local gtable   = require("gears.table")
local clib     = require("modules.color")
local clrutils = require("utils.color")

-- Load default AwesomeWM theme
local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

-- Get options from cozyconf
local fontset = require("theme.fonts.modern")
local theme_name  = "nord"
local theme_style = "dark"

-- █▀█ ▄▀█ █░░ █▀▀ ▀█▀ ▀█▀ █▀▀    █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- █▀▀ █▀█ █▄▄ ██▄ ░█░ ░█░ ██▄    █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ 

local path = "theme.colorschemes." .. theme_name .. "." .. theme_style
local cscheme = require(path)

-- Generate 5 primary colors
local pbase = cscheme.primary.base
cscheme.primary[500] = clrutils.darken(pbase, 0.4)
cscheme.primary[400] = clrutils.darken(pbase, 0.2)
cscheme.primary[300] = pbase
cscheme.primary[200] = clrutils.lighten(pbase, 0.2)
cscheme.primary[100] = clrutils.lighten(pbase, 0.4)

-- Generate 9 neutral colors
local ndark = cscheme.neutral.dark
local nbase = cscheme.neutral.base
local nlight = cscheme.neutral.light

cscheme.neutral[900] = ndark
cscheme.neutral[700] = clrutils.blend(ndark, nbase)
cscheme.neutral[500] = nbase
cscheme.neutral[300] = clrutils.blend(nbase, nlight)
cscheme.neutral[100] = nlight

cscheme.neutral[800] = clrutils.blend(ndark, cscheme.neutral[700])
cscheme.neutral[600] = clrutils.blend(cscheme.neutral[700], nbase)
cscheme.neutral[400] = clrutils.blend(cscheme.neutral[300], nbase)
cscheme.neutral[200] = clrutils.blend(nlight, cscheme.neutral[300])

-- Generate 5 reds
local red_base = cscheme.colors.red

cscheme.red = {}
cscheme.red[500] = clrutils.darken(red_base, 0.3)
cscheme.red[400] = clrutils.darken(red_base, 0.15)
cscheme.red[300] = red_base
cscheme.red[200] = clrutils.lighten(red_base, 0.15)
cscheme.red[100] = clrutils.lighten(red_base, 0.3)

-- Generate 5 greens
local green_base = cscheme.colors.green

cscheme.green = {}
cscheme.green[500] = clrutils.darken(green_base, 0.3)
cscheme.green[400] = clrutils.darken(green_base, 0.15)
cscheme.green[300] = green_base
cscheme.green[200] = clrutils.lighten(green_base, 0.15)
cscheme.green[100] = clrutils.lighten(green_base, 0.3)

-- Generate 5 yellows
local yellow_base = cscheme.colors.yellow

cscheme.yellow = {}
cscheme.yellow[500] = clrutils.darken(yellow_base, 0.3)
cscheme.yellow[400] = clrutils.darken(yellow_base, 0.15)
cscheme.yellow[300] = yellow_base
cscheme.yellow[200] = clrutils.lighten(yellow_base, 0.15)
cscheme.yellow[100] = clrutils.lighten(yellow_base, 0.3)

function cscheme.random_accent_color()
  return "#bf616a"
end

-----------

theme.fg = cscheme.neutral[100]

theme.wibar_fg        = cscheme.neutral[100]
theme.wibar_focused   = cscheme.primary[300]
theme.wibar_empty     = cscheme.neutral[600]
theme.wibar_occupied  = cscheme.neutral[100]

theme.notif_bg = cscheme.neutral[900]
theme.notif_actions_bg = cscheme.neutral[800]
theme.notif_timeout_bg = cscheme.neutral[800]

theme.wallpaper = gears.surface.load_uncached(cscheme.wall)

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
theme.border_width = dpi(3)
theme.border_color_active = cscheme.primary[300]
theme.border_color_normal = cscheme.neutral[900]

theme.border_radius = 10

-----------

gtable.crush(theme, cscheme)
gtable.crush(theme, fontset)

return theme
