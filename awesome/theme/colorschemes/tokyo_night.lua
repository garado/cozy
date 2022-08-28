
-- ▀█▀ █▀█ █▄▀ █▄█ █▀█   █▄░█ █ █▀▀ █░█ ▀█▀
-- ░█░ █▄█ █░█ ░█░ █▄█   █░▀█ █ █▄█ █▀█ ░█░

local gears = require("gears")
local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local math = math

-- █▀▀ █▀█ █░░ █▀█ █▀█ █▀
-- █▄▄ █▄█ █▄▄ █▄█ █▀▄ ▄█
-- Colors taken from:
-- https://github.com/folke/tokyonight.nvim
theme.bg_dark = "#1f2335"  
theme.bg_dark2 = "#222331" -- custom
theme.bg_dark3 = "#1a1b26" -- custom
theme.bg = "#24283b"
theme.bg_highlight = "#292e42"
theme.terminal_black = "#414868"
theme.fg = "#c0caf5"
theme.fg_dark = "#a9b1d6"
theme.fg_gutter = "#3b4261"
theme.dark3 = "#545c7e"
theme.comment = "#565f89"
theme.dark5 = "#737aa2"
theme.blue0 = "#3d59a1"
theme.blue = "#7aa2f7"
theme.cyan = "#7dcfff"
theme.blue1 = "#2ac3de"
theme.blue2 = "#0db9d7"
theme.blue5 = "#89ddff"
theme.blue6 = "#B4F9F8"
theme.blue7 = "#394b70"
theme.magenta = "#bb9af7"
theme.magenta2 = "#ff007c"
theme.purple = "#9d7cd8"
theme.orange = "#ff9e64"
theme.yellow = "#e0af68"
theme.green = "#9ece6a"
theme.green1 = "#73daca"
theme.green2 = "#41a6b5"
theme.teal = "#1abc9c"
theme.red = "#f7768e"
theme.red1 = "#db4b4b"

theme.transparent = "#ffffff00"

theme.accents = {
  theme.blue,
  theme.blue0,
  theme.cyan,
  theme.magenta,
  theme.magenta2,
  theme.orange,
  theme.yellow,
  theme.green,
  theme.teal,
  theme.red,
  theme.green2,
}

function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- color groupings
-- inspiration taken from the catppuccin style guide
-- background colors
theme.base          = theme.bg_dark3  -- dash, wibar
theme.crust         = theme.bg_dark2  -- widget bg
theme.mantle        = theme.bg_dark
theme.surface0      = theme.bg_highlight -- dash button bg 
theme.surface1      = theme.dark3     --
theme.overlay       = theme.bg_highlight -- album art filters

-- typography
theme.fg            = theme.fg      -- main text
theme.subtitle      = theme.fg_gutter
theme.subtext       = theme.fg_gutter
theme.main_accent   = theme.blue0   -- primary accent color

-- changing colors up to this point should be all you need
-- to change the entire color scheme.
-- but if you want even more fine-grained color customization, 
-- you can control the colors for almost every single UI element 
-- below.


-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█
theme.font_name = "RobotoMono Nerd Font Mono "
theme.font = theme.font_name .. "Regular "
theme.alt_font_name = "Roboto "
theme.alt_font = theme.alt_font_name .. "Regular "



-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█

-- Images
theme.wallpaper = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/walls/tokyo_night.png")

-- Dashboard
theme.dash_bg         = theme.base
theme.dash_widget_bg  = theme.crust
theme.dash_tab_bg     = theme.crust
theme.dash_header_fg  = theme.main_accent
theme.dash_tab_fg     = theme.fg
theme.fetch_title     = theme.main_accent
theme.fetch_value     = theme.fg
theme.habit_freq      = theme.main_accent
theme.hab_uncheck_fg  = theme.fg
theme.hab_uncheck_bg  = theme.subtext
theme.hab_check_fg    = theme.fg
theme.hab_check_bg    = theme.main_accent
theme.timedate        = theme.main_accent
theme.arcchart_colors = theme.accents
theme.income_fg       = theme.green
theme.expense_fg      = theme.red
theme.legend_amount   = theme.subtitle
theme.account_title   = theme.subtitle
theme.album_filter_1  = theme.overlay
theme.album_filter_2  = theme.overlay
theme.now_playing_fg  = theme.fg
theme.playerctl_bg    = theme.main_accent .. "00"
theme.display_name_fg = theme.main_accent
theme.title_fg        = theme.fg

-- Bar
theme.wibar_bg        = theme.base
theme.wibar_focused   = theme.main_accent
theme.wibar_occupied  = theme.fg
theme.wibar_empty     = theme.mantle
theme.bat_charging    = theme.green
theme.bat_normal      = theme.fg
theme.bat_low         = theme.red
theme.slider_bg       = theme.surface1
theme.brightbar_fg    = theme.main_accent
theme.volbar_fg       = theme.main_accent
theme.wibar_clock     = theme.fg

-- Control center
theme.ctrl_bg = theme.crust

-- Notifications
theme.notif_bg          = theme.crust
theme.notif_actions_bg  = theme.mantle
theme.notif_timeout_bg  = theme.mantle
theme.notif_dismiss_bg  = theme.transparent
theme.notification_spacing = dpi(10)

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
theme.border_width = dpi(3)
theme.border_color_active = theme.main_accent
theme.border_color_normal = theme.subtext

-- Corner radius
-- (not used for client rounding - used for rounding of other UI
-- components)
theme.border_radius = 10

-- Hotkeys
theme.hotkeys_bg = theme.crust
theme.hotkeys_fg = theme.fg
theme.hotkeys_modifiers_fg = theme.main_accent
theme.hotkeys_border_width = dpi(0)
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_font = theme.font .. "13"
theme.hotkeys_description_font = theme.alt_font .. "12"

return theme
