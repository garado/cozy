-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- get user's color scheme
local theme_name = require("user_variables").theme
local theme = require("theme/colorschemes/" .. theme_name)

theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")
theme.transparent = "#ffffff00"

-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█
theme.font_name = "RobotoMono Nerd Font Mono "
theme.font = theme.font_name .. "Regular "
theme.alt_font_name = "Roboto "
theme.alt_font = theme.alt_font_name .. "Regular "

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█
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
theme.hab_uncheck_bg  = theme.surface1
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
theme.ctrl_host = theme.subtitle
theme.ctrl_uptime = theme.subtitle
theme.ctrl_link_fg = theme.fg
theme.ctrl_link_bg = theme.surface0
theme.ctrl_lowerbar_bg = theme.base
theme.ctrl_power_options_bg = theme.mantle
theme.ctrl_qa_btn_bg = theme.surface0
theme.ctrl_power_options_btn_fg = theme.fg 

-- Notifications
theme.notif_bg          = theme.crust
theme.notif_actions_bg  = theme.mantle
theme.notif_timeout_bg  = theme.mantle
theme.notif_dismiss_bg  = theme.notif_bg
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
