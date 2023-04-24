
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")

local fontset = require("theme.fonts.modern")

-- Get user's color scheme
local theme_name  = "nord"
local theme_style = "dark"
local colorscheme = require("theme.colorschemes." .. theme_name .. "." .. theme_style)
local colors = colorscheme.colors

-- Automagically match system color schemes with Awesome
-- color scheme
local do_theme_integration = false
if do_theme_integration then
  require("theme/theme_integration")()
end

-- Theme-agnostic settings
-- theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
theme.wallpaper = gears.surface.load_uncached(colorscheme.wall_path)

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█

theme.fg = theme.fg_0

theme.ui_border_radius = dpi(5)

function theme.random_accent_color()
  local i = math.random(1, #colors.accents)
  return colors.accents[i]
end

theme.gradient = {
  colors.primary_0,
  colors.primary_1,
  colors.primary_2,
  colors.primary_3,
  colors.primary_4,
  colors.primary_4,
}

-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 
-- Basic dash settings
theme.dash_bg         = colors.bg_0
theme.dash_widget_bg  = colors.bg_1
theme.dash_widget_sel = colors.bg_2
theme.dash_header_fg  = colors.primary_0
theme.dash_tab_fg     = colors.fg_0
theme.dash_tab_bg     = colors.bg_1

-- Profile picture
theme.prof_name_fg    = colors.primary_0
theme.prof_pfp_bg     = colors.primary_0
theme.prof_title_fg   = colors.fg_0

-- Time and date
theme.timedate        = colors.primary_0

-- Music player
theme.mus_filter_1    = colors.bg_4
theme.mus_filter_2    = colors.bg_4
theme.mus_playing_fg  = colors.fg_0
theme.mus_control_bg  = colors.primary_0.."00"
theme.mus_control_fg  = colors.fg_0
theme.mus_bg          = colors.bg_3

-- Finances
theme.cash_arccolors  = colors.accents
theme.cash_income_fg  = colors.green
theme.cash_expense_fg = colors.red
theme.cash_alttext_fg = colors.fg_2
theme.cash_acct_name  = colors.fg_1
theme.cash_action_btn = colors.bg_3
theme.cash_budgetbar_bg = colors.bg_2

-- Habits
theme.hab_freq        = colors.primary_0
theme.hab_uncheck_fg  = colors.fg_0
theme.hab_uncheck_bg  = colors.bg_3
theme.hab_check_fg    = colors.fg_0
theme.hab_check_bg    = colors.primary_0
theme.hab_selected_bg = colors.primary_0
theme.hab_selected_fg = colors.fg_0

-- Timewarrior
theme.timew_header_fg = colors.fg_1
theme.timew_btn_bg    = colors.bg_3

-- Fetch (unused)
theme.fetch_title     = colors.primary_0
theme.fetch_value     = colors.fg_0

-- Calendar
theme.cal_fg = colors.fg_0
theme.cal_bg = theme.dash_widget_bg
theme.cal_weekday_fg = colors.fg_0
theme.cal_header_fg = colors.fg_0
theme.cal_month_bg = theme.dash_widget_bg
theme.cal_focus_fg = colors.primary_0
theme.cal_focus_bg = theme.dash_widget_bg
theme.cal_today_bg = theme.red
theme.calendar_spacing = dpi(10)
theme.calendar_long_weekdays = true

-- Tasks
theme.task_prompt_contbg = theme.bg_l0
theme.task_prompt_textbg = theme.bg_l1
theme.task_due_fg        = colors.fg_1
theme.task_overdue_fg    = colors.red
theme.task_next_fg       = colors.yellow
theme.task_selected_fg   = colors.primary_0
theme.task_scrollbar_bg  = colors.bg_4
theme.task_scrollbar_fg  = colors.primary_1

-- Timewarrior
theme.timew_cal_heatmap_accent = colors.primary_0

-- █▄▄ ▄▀█ █▀█ 
-- █▄█ █▀█ █▀▄ 
theme.wibar_bg        = colors.bg_0
theme.wibar_fg        = colors.fg_0
theme.wibar_accent    = colors.primary_0
theme.wibar_focused   = theme.wibar_accent
theme.wibar_occupied  = colors.fg_2
theme.wibar_empty     = colors.bg_2
theme.wibar_slider_bg = colors.bg_3
theme.wibar_bright_fg = theme.wibar_accent
theme.wibar_vol_fg    = theme.wibar_accent
theme.wibar_notif_fg  = theme.wibar_accent
theme.wibar_launch_app    = theme.wibar_fg
theme.wibar_launch_dash   = theme.wibar_fg
theme.wibar_launch_ctrl   = theme.wibar_fg
theme.wibar_launch_theme  = theme.wibar_fg
theme.wibar_launch_hover  = colors.primary_0

-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 
theme.ctrl_fg       = colors.fg_0
theme.ctrl_bg       = colors.bg_1
theme.ctrl_host     = colors.fg_2
theme.ctrl_uptime   = colors.fg_2
theme.ctrl_link_fg  = colors.fg_0
theme.ctrl_link_bg  = colors.bg_3
theme.ctrl_qa_btn_bg     = colors.bg_3
theme.ctrl_lowerbar_bg   = colors.bg_0
theme.ctrl_powopt_bg     = colors.bg_2
theme.ctrl_powopt_btn_fg = colors.fg_0

theme.ctrl_cpu_accent = colors.primary_0
theme.ctrl_ram_accent = colors.primary_0
theme.ctrl_hdd_accent = colors.primary_0

theme.ctrl_header_fg = colors.fg_0
theme.ctrl_pfp_bg   = colors.primary_0

theme.ctrl_fetch_accent = colors.primary_0
theme.ctrl_fetch_value  = colors.fg_0

theme.ctrl_stats_bg   = colors.bg_3

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
theme.switcher_bg          = colors.bg_1
theme.switcher_act_btn_bg  = colors.bg_1
theme.switcher_opt_btn_bg  = colors.bg_3
theme.switcher_header_fg   = colors.primary_0

-- █▄░█ █▀█ ▀█▀ █ █▀▀ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █░▀█ █▄█ ░█░ █ █▀░ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 
theme.notif_bg          = colors.bg_1
theme.notif_actions_bg  = colors.bg_2
theme.notif_timeout_bg  = colors.bg_2
theme.notif_dismiss_bg  = colors.bg_1
theme.notification_spacing = dpi(10)
theme.notification_border_color = theme.notif_bg

-- █▀▄▀█ █ █▀ █▀▀ 
-- █░▀░█ █ ▄█ █▄▄ 
-- Layout list
theme.layout_bg = colors.bg_1

-- Bling mstab
theme.mstab_bar_disable = false
theme.mstab_bar_ontop = false
theme.mstab_border_radius = 0
theme.mstab_tabbar_position = "top"
theme.mstab_tabbar_style = "default"
theme.mstab_master_position = "right"
theme.tabbed_bg_focus = colors.primary_0
theme.tabbed_fg_focus = colors.fg_0
theme.tabbar_bg_normal = colors.bg_1
theme.tabbar_fg_normal = colors.bg_4

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
theme.border_width = dpi(3)
theme.border_color_active = colors.primary_0
theme.border_color_normal = colors.bg_0

-- Corner radius
-- (not used for client rounding - used for rounding of other UI
-- components)
theme.border_radius = 10

-- Hotkeys
theme.hotkeys_modifiers_fg = colors.primary_0
theme.hotkeys_bg = colors.bg_1
theme.hotkeys_fg = colors.fg_0
theme.hotkeys_border_width = dpi(0)
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_font = theme.alt_small_font
theme.hotkeys_description_font = theme.base_small_font

theme.transparent = "#ff000000"

-- Override default vars with vars defined in colorscheme
gears.table.crush(theme, fontset)
gears.table.crush(theme, colorscheme.colors)
gears.table.crush(theme, colorscheme.override)

return theme
