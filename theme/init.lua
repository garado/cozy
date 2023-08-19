-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local dpi      = require("utils.ui").dpi
local gfs      = require("gears.filesystem")
local conf     = require("cozyconf")
local gears    = require("gears")
local gtable   = require("gears.table")
local clrutils = require("utils.color")

-- Load default AwesomeWM theme
local theme    = dofile(gfs.get_themes_dir() .. "default/theme.lua")

theme.pfp      = gfs.get_configuration_dir() .. "theme/assets/pfp.png"

if conf.theme_switch_integration then
  require("theme.integration")
end


-- █▀▀ █▀█ █▄░█ ▀█▀    █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █▀░ █▄█ █░▀█ ░█░    █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ ░█░ █ █▄█ █░▀█

local _font = require("theme.fonts." .. conf.fontset)
local font = {}

for w_name, w_val in pairs(_font.font_weights) do
  for s_name, s_val in pairs(_font.font_sizes) do
    local fval  = _font.font_name .. w_val .. s_val
    local fname = 'font_' .. w_name .. '_' .. s_name
    font[fname] = fval
  end
end

for w_name, w_val in pairs(_font.alt_font_weights) do
  for s_name, s_val in pairs(_font.alt_font_sizes) do
    local fval  = _font.alt_font_name .. w_val .. s_val
    local fname = 'altfont_' .. w_name .. '_' .. s_name
    font[fname] = fval
  end
end


-- █▀█ ▄▀█ █░░ █▀▀ ▀█▀ ▀█▀ █▀▀    █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █▀▀ █▀█ █▄▄ ██▄ ░█░ ░█░ ██▄    █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ ░█░ █ █▄█ █░▀█

local path           = "theme.colorschemes." .. conf.theme_name .. "." .. conf.theme_style
local cscheme        = require(path)

-- Generate 7 primary colors
local pbase          = cscheme.primary.base

-- For light-theme colorschemes, dark/light are inverted.
local darken         = cscheme.type == "dark" and clrutils.darken or clrutils.lighten
local lighten        = cscheme.type == "dark" and clrutils.lighten or clrutils.darken

cscheme.primary[900] = darken(pbase, 0.54)
cscheme.primary[800] = darken(pbase, 0.48)
cscheme.primary[700] = darken(pbase, 0.32)
cscheme.primary[600] = darken(pbase, 0.16)
cscheme.primary[500] = pbase
cscheme.primary[400] = lighten(pbase, 0.16)
cscheme.primary[300] = lighten(pbase, 0.32)
cscheme.primary[200] = lighten(pbase, 0.48)
cscheme.primary[100] = lighten(pbase, 0.54)

-- Generate 9 neutral colors
local ndark          = cscheme.neutral.dark
local nbase          = cscheme.neutral.base
local nlight         = cscheme.neutral.light

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
local red_base       = cscheme.colors.red

cscheme.red          = {}
cscheme.red[500]     = darken(red_base, 0.3)
cscheme.red[400]     = darken(red_base, 0.15)
cscheme.red[300]     = red_base
cscheme.red[200]     = lighten(red_base, 0.15)
cscheme.red[100]     = lighten(red_base, 0.3)

-- Generate 5 greens
local green_base     = cscheme.colors.green

cscheme.green        = {}
cscheme.green[500]   = darken(green_base, 0.3)
cscheme.green[400]   = darken(green_base, 0.15)
cscheme.green[300]   = green_base
cscheme.green[200]   = lighten(green_base, 0.15)
cscheme.green[100]   = lighten(green_base, 0.3)

-- Generate 5 yellows
local yellow_base    = cscheme.colors.yellow

cscheme.yellow       = {}
cscheme.yellow[500]  = darken(yellow_base, 0.3)
cscheme.yellow[400]  = darken(yellow_base, 0.15)
cscheme.yellow[300]  = yellow_base
cscheme.yellow[200]  = lighten(yellow_base, 0.15)
cscheme.yellow[100]  = lighten(yellow_base, 0.3)

function cscheme.random_accent_color()
  local i = math.random(1, #cscheme.accents)
  return cscheme.accents[i]
end

-----------

theme.fg                   = cscheme.neutral[100]

theme.dash_widget_gap      = dpi(15)

theme.wibar_fg             = cscheme.neutral[100]
theme.wibar_focused        = cscheme.primary[300]
theme.wibar_empty          = cscheme.neutral[600]
theme.wibar_occupied       = cscheme.neutral[100]

theme.notif_bg             = cscheme.neutral[900]
theme.notif_actions_bg     = cscheme.neutral[800]
theme.notif_timeout_bg     = cscheme.neutral[800]
theme.notification_spacing = dpi(10)

theme.wallpaper            = gears.surface.load_uncached(cscheme.wall)

-- Gaps
theme.useless_gap          = dpi(7)

-- Borders
theme.border_width         = dpi(3)
theme.border_color_active  = cscheme.primary[300]
theme.border_color_normal  = cscheme.neutral[900]

theme.border_radius        = 10

-----------

gtable.crush(theme, font)
gtable.crush(theme, cscheme)

return theme
