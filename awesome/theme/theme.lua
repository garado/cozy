
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- get user's color scheme
local theme_name = require("user_variables").theme
local theme = require("theme/colorschemes/" .. theme_name)

-- theme-agnostic settings
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- automagically match system color schemes with awesome
-- color scheme
local switch = require("theme/theme_switcher")()

-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█
theme.font_name = "RobotoMono Nerd Font Mono "
theme.font = theme.font_name .. "Regular "
theme.alt_font_name = "Roboto "
theme.alt_font = theme.alt_font_name .. "Regular "

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█
-- element name       = dont touch if it was  OR  set to default value
--                      custom set already        if not assigned yet

-- Dashboard
theme.dash_bg         = theme.dash_bg         or theme.base
theme.dash_widget_bg  = theme.dash_widget_bg  or theme.crust
theme.dash_header_fg  = theme.dash_header_fg  or theme.main_accent
theme.dash_tab_fg     = theme.dash_tab_fg     or theme.fg
theme.dash_tab_bg     = theme.dash_tab_bg     or theme.crust
theme.fetch_title     = theme.fetch_title     or theme.main_accent
theme.fetch_value     = theme.fetch_value     or theme.fg
theme.habit_freq      = theme.habit_freq      or theme.main_accent
theme.hab_uncheck_fg  = theme.hab_uncheck_fg  or theme.fg
theme.hab_uncheck_bg  = theme.hab_uncheck_bg  or theme.surface1
theme.hab_check_fg    = theme.hab_check_fg    or theme.fg
theme.hab_check_bg    = theme.hab_check_bg    or theme.main_accent
theme.timedate        = theme.timedate        or theme.main_accent
theme.arcchart_colors = theme.arcchart_colors or theme.accents
theme.income_fg       = theme.income_fg       or theme.green
theme.expense_fg      = theme.expense_fg      or theme.red
theme.legend_amount   = theme.legened_amount  or theme.subtitle
theme.account_title   = theme.account_title   or theme.subtitle
theme.album_filter_1  = theme.album_filter_1  or theme.overlay0
theme.album_filter_2  = theme.album_filter_2  or theme.overlay0
theme.now_playing_fg  = theme.now_playing_    or theme.fg
theme.playerctl_bg    = theme.playerctl_bg    or theme.main_accent .. "00"
theme.display_name_fg = theme.display_name_fg or theme.main_accent
theme.pfp_bg          = theme.pfp_bg          or theme.main_accent
theme.title_fg        = theme.title_fg        or theme.fg

-- Bar
theme.wibar_bg        = theme.wibar_bg        or theme.base
theme.wibar_focused   = theme.wibar_focused   or theme.main_accent
theme.wibar_occupied  = theme.wibar_occupied  or theme.fg
theme.wibar_empty     = theme.wibar_empty     or theme.mantle
theme.bat_charging    = theme.bat_chargin     or theme.green
theme.bat_normal      = theme.bat_normal      or theme.fg
theme.bat_low         = theme.bat_low         or theme.red
theme.slider_bg       = theme.slider_bg       or theme.surface1
theme.brightbar_fg    = theme.brightbar_fg    or theme.main_accent
theme.volbar_fg       = theme.volbar_fg       or theme.main_accent
theme.notif_toggle_fg = theme.notif_toggle_fg or theme.main_accent
theme.wibar_clock     = theme.wibar_clock     or theme.fg

-- Control center
theme.ctrl_bg       = theme.ctrl_bg       or theme.crust
theme.ctrl_host     = theme.ctrl_host     or theme.subtitle
theme.ctrl_uptime   = theme.ctrl_uptime   or theme.subtitle
theme.ctrl_link_fg  = theme.ctrl_link_fg  or theme.fg
theme.ctrl_link_bg  = theme.ctrl_link_bg  or theme.surface0
theme.ctrl_qa_btn_bg            = theme.ctrl_qa_btn_bg or theme.surface0
theme.ctrl_lowerbar_bg          = theme.ctrl_lowerbar_bg  or theme.base
theme.ctrl_power_options_bg     = theme.ctrl_power_options_bg or theme.mantle
theme.ctrl_power_options_btn_fg = theme.ctrl_power_options_btn_ or theme.fg 

-- Settings
theme.settings_cancel_btn_bg = theme.settings_cancel_btn_bg or theme.base
theme.settings_apply_btn_bg = theme.settings_apply_btn_bg or theme.base


-- Notifications
theme.notif_bg          = theme.notif_bg          or theme.crust
theme.notif_actions_bg  = theme.notif_actions_bg  or theme.mantle
theme.notif_timeout_bg  = theme.notif_timeout_bg  or theme.mantle
theme.notif_dismiss_bg  = theme.notif_dismiss_bg  or theme.notif_bg
theme.notification_spacing = dpi(10)

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
theme.border_width = dpi(3)
theme.border_color_active = theme.border_color_active or theme.main_accent
theme.border_color_normal = theme.border_color_normal or theme.overlay1

-- Corner radius
-- (not used for client rounding - used for rounding of other UI
-- components)
theme.border_radius = 10

-- Hotkeys
theme.hotkeys_bg = theme.hotkeys_bg   or theme.crust
theme.hotkeys_fg = theme.hotkeys_fg   or theme.fg
theme.hotkeys_modifiers_fg = hotkeys_modifiers_fg or  theme.main_accent
theme.hotkeys_border_width = dpi(0)
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_font = theme.font .. "13"
theme.hotkeys_description_font = theme.font .. "12"

return theme
