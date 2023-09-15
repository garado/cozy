-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local dpi      = require("utils.ui").dpi
local gfs      = require("gears.filesystem")
local conf     = require("cozyconf")
local gears    = require("gears")
local gtable   = require("gears.table")

-- Load default AwesomeWM theme
local theme = dofile(gfs.get_themes_dir() .. "default/theme.lua")

if conf.theme_switch_integration == true then
  require("theme.integration")(conf.theme_name, conf.theme_style)
end

-- Font generation
local _font = conf.font
local font = {}

for w_name, w_val in pairs(_font.weights) do
  for s_name, s_val in pairs(_font.sizes) do
    local fval  = _font.name.. w_val .. dpi(s_val)
    local fname = 'font_' .. w_name .. '_' .. s_name
    font[fname] = fval
  end
end

-- Palette generation
local cscheme = require("theme.palettegen")(conf.theme_name, conf.theme_style)

-- Set other misc theme variables
theme.pfp = gfs.get_configuration_dir() .. "theme/assets/pfp.png"
theme.wallpaper = gears.surface.load_uncached(cscheme.wall)

theme.useless_gap = dpi(7)
theme.dash_widget_gap = dpi(15)
theme.notification_spacing = dpi(10)

theme.border_width = dpi(3)
theme.border_color_active = cscheme.primary[300]
theme.border_color_normal = cscheme.neutral[900]

theme.border_radius = dpi(10)

gtable.crush(theme, font)
gtable.crush(theme, cscheme)
return theme
