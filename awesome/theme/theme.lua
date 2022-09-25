
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local user_vars = require("user_variables")

-- Get user's color scheme
local theme_name = user_vars.theme_name
local theme_style = user_vars.theme_style
local theme = require("theme.colorschemes." .. theme_name .. "." .. theme_style)

-- Theme-agnostic settings
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- Automagically match system color schemes with awesome
-- color scheme
local do_theme_integration = user_vars.theme_switch_integration
if do_theme_integration then
  require("theme/theme_switcher")()
end

-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█
theme.font_name = "RobotoMono Nerd Font Mono "
theme.font = theme.font_name .. "Regular "
theme.alt_font_name = "Roboto "
theme.alt_font = theme.alt_font_name .. "Regular "

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█
function theme.random_accent_color()
  local i = math.random(1, #theme.accents)
  return theme.accents[i]
end

-- Dashboard
theme.dash_bg         = theme.dash_bg         or theme.bg
theme.dash_widget_bg  = theme.dash_widget_bg  or theme.bg_l0
theme.dash_widget_sel = theme.dash_widget_sel or theme.bg_l1
theme.dash_header_fg  = theme.dash_header_fg  or theme.main_accent
theme.dash_tab_fg     = theme.dash_tab_fg     or theme.fg
theme.dash_tab_bg     = theme.dash_tab_bg     or theme.bg_l0

theme.prof_name_fg    = theme.prof_name_fg    or theme.main_accent
theme.prof_pfp_bg     = theme.prof_pfp_bg     or theme.main_accent
theme.prof_title_fg   = theme.prof_title_fg   or theme.fg

theme.timedate        = theme.timedate        or theme.main_accent

theme.mus_filter_1    = theme.mus_filter_1    or theme.bg_l3
theme.mus_filter_2    = theme.mus_filter_2    or theme.bg_l3
theme.mus_playing_fg  = theme.mus_playing_fg  or theme.fg
theme.mus_control_bg  = theme.mus_control_bg  or theme.main_accent.."00"
theme.mus_control_fg  = theme.mus_control_fg  or theme.fg
theme.mus_bg          = theme.mus_bg          or theme.bg_l2

theme.task_due_fg     = theme.task_due_fg     or theme.fg_sub

theme.cash_arccolors  = theme.cash_arccolors  or theme.accents
theme.cash_income_fg  = theme.cash_income_fg  or theme.green
theme.cash_expense_fg = theme.cash_expense_fg or theme.red
theme.cash_alttext_fg = theme.cash_alttext_fg or theme.fg_alt
theme.cash_acct_name  = theme.cash_acct_name  or theme.fg_sub
theme.cash_action_btn = theme.cash_action_btn or theme.bg_l2
theme.cash_budgetbar_bg = theme.cash_budgetbar_bg or theme.bg_l1

theme.hab_freq        = theme.hab_freq        or theme.main_accent
theme.hab_uncheck_fg  = theme.hab_uncheck_fg  or theme.fg
theme.hab_uncheck_bg  = theme.hab_uncheck_bg  or theme.bg_l2
theme.hab_check_fg    = theme.hab_check_fg    or theme.fg
theme.hab_check_bg    = theme.hab_check_bg    or theme.main_accent
theme.hab_selected_bg = theme.hab_selected_bg or theme.red
theme.hab_selected_fg = theme.hab_selected_fg or theme.fg

theme.timew_header_fg = theme.timew_header_fg or theme.fg_sub
theme.timew_btn_bg    = theme.timew_btn_bg    or theme.bg_l2

theme.fetch_title     = theme.fetch_title     or theme.main_accent
theme.fetch_value     = theme.fetch_value     or theme.fg

theme.cal_fg = theme.cal_fg or theme.fg
theme.cal_bg = theme.cal_bg or theme.dash_widget_bg
theme.cal_weekday_fg = theme.cal_weekday_fg or theme.fg
theme.cal_header_fg = theme.cal_header_fg or theme.fg
theme.cal_month_bg = theme.cal_month_bg or theme.dash_widget_bg
theme.cal_focus_fg = theme.cal_focus_fg or theme.main_accent
theme.cal_focus_bg = theme.cal_focus_bg or theme.dash_widget_bg
theme.calendar_spacing = dpi(10)
theme.calendar_long_weekdays = true

theme.task_prompt_contbg = theme.bg_l0
theme.task_prompt_textbg = theme.bg_l1

-- Bar
theme.wibar_bg        = theme.wibar_bg        or theme.bg
theme.wibar_fg        = theme.wibar_fg        or theme.fg
theme.wibar_accent    = theme.wibar_accent    or theme.main_accent
theme.wibar_focused   = theme.wibar_focused   or theme.wibar_accent
theme.wibar_occupied  = theme.wibar_occupied  or theme.fg_alt
theme.wibar_empty     = theme.wibar_empty     or theme.bg_l1
theme.wibar_bat_grn   = theme.bat_chargin     or theme.green
theme.wibar_bat_nrml  = theme.wibar_bat_nrml  or theme.wibar_fg
theme.wibar_bat_red   = theme.wibar_bat_red   or theme.red
theme.wibar_slider_bg = theme.wibar_slider_bg or theme.bg_l2
theme.wibar_bright_fg = theme.wibar_bright_fg or theme.wibar_accent
theme.wibar_vol_fg    = theme.wibar_vol_fg    or theme.wibar_accent
theme.wibar_notif_fg  = theme.wibar_notif_fg  or theme.wibar_accent
theme.wibar_clock     = theme.wibar_clock     or theme.wibar_fg
theme.wibar_launch_app    = theme.wibar_launch_app    or theme.wibar_fg
theme.wibar_launch_dash   = theme.wibar_launch_dash   or theme.wibar_fg
theme.wibar_launch_ctrl   = theme.wibar_launch_ctrl   or theme.wibar_fg
theme.wibar_launch_theme  = theme.wibar_launch_theme  or theme.wibar_fg
theme.wibar_launch_hover  = theme.wibar_launch_hover  or theme.main_accent

-- Control center
theme.ctrl_fg       = theme.ctrl_fg       or theme.fg
theme.ctrl_bg       = theme.ctrl_bg       or theme.bg_l0
theme.ctrl_host     = theme.ctrl_host     or theme.fg_alt
theme.ctrl_uptime   = theme.ctrl_uptime   or theme.fg_alt
theme.ctrl_link_fg  = theme.ctrl_link_fg  or theme.fg
theme.ctrl_link_bg  = theme.ctrl_link_bg  or theme.bg_l2
theme.ctrl_qa_btn_bg     = theme.ctrl_qa_btn_bg     or theme.bg_l2
theme.ctrl_lowerbar_bg   = theme.ctrl_lowerbar_bg   or theme.bg
theme.ctrl_powopt_bg     = theme.ctrl_powopt_bg     or theme.bg_l1
theme.ctrl_powopt_btn_fg = theme.ctrl_powopt_btn_fg or theme.fg

theme.ctrl_cpu_accent = theme.ctrl_cpu_accent or theme.main_accent
theme.ctrl_ram_accent = theme.ctrl_ram_accent or theme.main_accent
theme.ctrl_hdd_accent = theme.ctrl_hdd_accent or theme.main_accent

theme.ctrl_header_fg = theme.ctrl_header_fg or theme.fg
theme.ctrl_pfp_bg   = theme.ctrl_pfp_bg or theme.main_accent

theme.ctrl_fetch_accent = theme.ctrl_fetch_accent or theme.main_accent
theme.ctrl_fetch_value  = theme.ctrl_fetch_value  or theme.fg

theme.ctrl_stats_bg   = theme.ctrl_stats_bg or theme.bg_l2

-- Theme switcher
theme.switcher_bg          = theme.switcher_bg         or theme.bg_l0
theme.switcher_act_btn_bg  = theme.switcher_act_btn_bg or theme.bg_l0
theme.switcher_opt_btn_bg  = theme.switcher_opt_btn_bg or theme.bg_l2
theme.switcher_lowbar_bg   = theme.switcher_lowbar_bg  or theme.bg
theme.switcher_header_fg   = theme.switcher_header_fg  or theme.main_accent

-- Notifications
theme.notif_bg          = theme.notif_bg          or theme.bg_l0
theme.notif_actions_bg  = theme.notif_actions_bg  or theme.bg_l1
theme.notif_timeout_bg  = theme.notif_timeout_bg  or theme.bg_l1
theme.notif_dismiss_bg  = theme.notif_dismiss_bg  or theme.bg_l0
theme.notification_spacing = dpi(10)
theme.notification_border_color = theme.notif_bg

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
theme.border_width = dpi(3)
theme.border_color_active = theme._border_color_active or theme.main_accent
theme.border_color_normal = theme._border_color_normal or theme.bg_l1

-- Corner radius
-- (not used for client rounding - used for rounding of other UI
-- components)
theme.border_radius = 10

-- Hotkeys
theme.hotkeys_modifiers_fg = theme.hotkeys_modifiers_fg or theme.main_accent
theme.hotkeys_bg = theme.hotkeys_bg or theme.bg_l0
theme.hotkeys_fg = theme.hotkeys_fg or theme.fg
theme.hotkeys_border_width = dpi(0)
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_font = theme.font .. "13"
theme.hotkeys_description_font = theme.font .. "12"

return theme
