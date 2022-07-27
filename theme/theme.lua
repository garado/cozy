-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
-- local helpers = require("helpers")
-- local icons = require("icons")


-- █▄░█ █▀█ █▀█ █▀▄
-- █░▀█ █▄█ █▀▄ █▄▀

-- Official colors
theme.nord0 = "#2e3440"   -- Polar night
theme.nord1 = "#3b4252"
theme.nord2 = "#434c5e"
theme.nord3 = "#4c566a"
theme.nord4 = "#d8dee9"   -- Snow storm
theme.nord5 = "#e5e9f0"
theme.nord6 = "#eceff4"
theme.nord7 = "#8fbcbb"   -- Frost
theme.nord8 = "#88c0d0"
theme.nord9 = "#81a1c1"
theme.nord10 = "#5e81ac"
theme.nord11 = "#bf616a"  -- Aurora
theme.nord12 = "#d08770"
theme.nord13 = "#ebcb8b"
theme.nord14 = "#a3be8c"
theme.nord15 = "#b48ead"

-- Custom Nord colors
theme.dark_polar_night = "#20242c"
theme.med_polar_night = "#373e4d"

-- Other
theme.transparent = "#000000"


-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█

theme.font_name = "Roboto Mono "
theme.font = theme.font_name .. "Medium 10"
--theme.icon_font = "Nerd Font"


-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

-- Background colors
theme.background = theme.nord1
theme.background_med = theme.med_polar_night
theme.background_dark = theme.dark_polar_night

-- Foreground colors
theme.xforeground = theme.nord6

-- Accent colors
-- Widgets
-- Titlebars

-- Wibar
theme.wibar_bg = theme.dark_polar_night
theme.wibar_focused = theme.nord7
theme.wibar_occupied = theme.nord6
theme.wibar_empty = theme.med_polar_night

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█

-- Wallpapers
theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/wall.png")

-- Gaps
theme.useless_gap = dpi(7)

-- Hotkeys
theme.hotkeys_bg = theme.dark_polar_night
theme.hotkeys_fg = theme.nord4
theme.hotkeys_modifiers_fg = theme.nord9
theme.hotkeys_font = "SH Pinscher 20"
theme.hotkeys_font = theme.font_name .. "Medium 12"
theme.hotkeys_description_font = theme.font_name .. "Regular 10"
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_border_width = dpi(0)

return theme
