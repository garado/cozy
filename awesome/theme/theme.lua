-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local math = math


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
theme.med2_polar_night = "#272c36"
theme.med_polar_night = "#373e4d"



-- Other
theme.transparent = "#ffffff00"

-- RPG Colors
theme.color1 = "#bda997"
theme.color2 = "#d4c2b6"
theme.color3 = "#fbf2eb"
theme.color4 = "#4d3f38"
theme.color5 = "#aa8c7a"
theme.color6 = "#c4ad9c"


-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█

theme.font_name = "RobotoMono Nerd Font Mono "
theme.font = theme.font_name .. "Regular "

theme.alt_font_name = "Roboto "
theme.alt_font = theme.alt_font_name .. "Regular "


-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█

-- Background colors
theme.background = theme.nord1
theme.background_med = theme.med_polar_night
theme.background_dark = theme.dark_polar_night

-- Foreground colors
theme.xforeground = theme.nord6

-- Accent colors
function theme.random_accent_color()
  local accents = {
    theme.nord10,
    theme.nord11,
    theme.nord12,
    theme.nord13,
    theme.nord14,
    theme.nord15,
  }

  local i = math.random(1, #accents)
  return accents[i]
end

-- Music player
theme.music_now_playing_fg = theme.nord4
theme.music_button_transparent = "#5e81ac00"

-- Widgets


-- Titlebars

-- Wibar
theme.wibar_bg = theme.dark_polar_night
theme.wibar_focused = theme.nord9
theme.wibar_occupied = theme.nord6
theme.wibar_empty = theme.med_polar_night

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█

-- Pictures
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- Wallpapers
theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/wall.png")

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
theme.border_width = dpi(2)
theme.border_color_active = theme.nord9
theme.border_color_normal = theme.med_polar_night

-- Corner radius
theme.border_radius = 10

-- Hotkeys
theme.hotkeys_bg = theme.dark_polar_night
theme.hotkeys_fg = theme.nord4
theme.hotkeys_modifiers_fg = theme.nord9
theme.hotkeys_font = "SH Pinscher 20"
theme.hotkeys_font = theme.font_name .. "Medium 12"
theme.hotkeys_description_font = theme.font_name .. "Regular 10"
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_border_width = dpi(0)

-- Notifications
theme.notification_spacing = dpi(5)
theme.notification_title_bg = theme.dark_polar_night
theme.notification_content_bg = theme.med2_polar_night
theme.notification_fg = theme.xforeground

-- Dash
theme.header_font_name = "Roboto "
theme.header_font = theme.header_font_name .. "Light "
theme.dash_bg = theme.dark_polar_night
theme.dash_widget_bg = theme.med2_polar_night
theme.dash_widget_fg = theme.nord6
theme.dash_header_color = theme.nord10
theme.dash_tab_bg = theme.med2_polar_night

theme.pomodoro_bar_fg = theme.nord10
theme.pomodoro_bar_bg = theme.dark_polar_night

-- Tag preview
theme.tag_preview_widget_margin = dpi(10)
theme.tag_preview_widget_border_radius = theme.border_radius
theme.tag_preview_client_border_radius = theme.border_radius / 2
theme.tag_preview_client_opacity = 1
theme.tag_preview_client_bg = theme.wibar_bg
theme.tag_preview_client_border_color = theme.wibar_bg
theme.tag_preview_client_border_width = 0
theme.tag_preview_widget_bg = theme.wibar_bg
theme.tag_preview_widget_border_color = theme.wibar_bg
theme.tag_preview_widget_border_width = 0

--- Tabs (bling)
-- For tabbed only
theme.tabbed_spawn_in_tab = true -- whether a new client should spawn into the focused tabbing container

-- For tabbar in general
theme.tabbar_ontop  = false
theme.tabbar_radius = 0                -- border radius of the tabbar
theme.tabbar_style = "default"         -- style of the tabbar ("default", "boxes" or "modern")
theme.tabbar_font = theme.font          -- font of the tabbar
theme.tabbar_size = 30                 -- size of the tabbar
theme.tabbar_position = "top"          -- position of the tabbar
theme.tabbar_bg_normal = theme.nord3-- background color of the focused client on the tabbar
theme.tabbar_fg_normal = "#ffffff"     -- foreground color of the focused client on the tabbar
theme.tabbar_bg_focus  = theme.dark_polar_night     -- background color of unfocused clients on the tabbar
theme.tabbar_fg_focus  = theme.nord9     -- foreground color of unfocused clients on the tabbar
theme.tabbar_bg_focus_inactive = nil   -- background color of the focused client on the tabbar when inactive
theme.tabbar_fg_focus_inactive = nil   -- foreground color of the focused client on the tabbar when inactive
theme.tabbar_bg_normal_inactive = nil  -- background color of unfocused clients on the tabbar when inactive
theme.tabbar_fg_normal_inactive = nil  -- foreground color of unfocused clients on the tabbar when inactive
theme.tabbar_disable = false -- disable the tab bar entirely

-- the following variables are currently only for the "modern" tabbar style
theme.tabbar_color_close = "#f9929b" -- changes the color of the close button
theme.tabbar_color_min   = "#fbdf90" -- changes the color of the minimize button
theme.tabbar_color_float = "#ccaced" -- changes the color of the float button

return theme
