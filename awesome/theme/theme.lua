
-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀
-- ░█░ █▀█ ██▄ █░▀░█ ██▄

local gears = require("gears")
local gfs = require("gears.filesystem")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local config = require("config")
local themes_path = gfs.get_themes_dir()
local theme = dofile(themes_path .. "default/theme.lua")

-- Get user's color scheme
local theme_name = config.theme_name
local theme_style = config.theme_style
local colorscheme = require("theme.colorschemes." .. theme_name .. "." .. theme_style)
local colors = colorscheme.colors

-- Automagically match system color schemes with awesome
-- color scheme
local do_theme_integration = config.theme_switch_integration
if do_theme_integration then
  require("theme/theme_switcher")()
end

-- Theme-agnostic settings
theme.pfp = gears.surface.load_uncached(gfs.get_configuration_dir() .. "theme/assets/pfp.png")

-- █░█░█ ▄▀█ █░░ █░░ 
-- ▀▄▀▄▀ █▀█ █▄▄ █▄▄ 
theme.wallpaper = gears.surface.load_uncached(colorscheme.wall_path)

-- █▀▀ █▀█ █▄░█ ▀█▀ █▀
-- █▀░ █▄█ █░▀█ ░█░ ▄█
-- theme.font_name = "DisposableDroid BB "
-- theme.font = theme.font_name .. "Regular "
-- theme.alt_font_name = theme.font_name
-- theme.alt_font = theme.alt_font_name .. "Regular "

theme.font_name = "RobotoMono Nerd Font Mono "
theme.font = theme.font_name .. "Regular "
theme.alt_font_name = "Roboto "
theme.alt_font = theme.alt_font_name .. "Regular "

-- █░█ █   █▀▀ █░░ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▄█ █   ██▄ █▄▄ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█
function theme.random_accent_color()
  local i = math.random(1, #colors.accents)
  return colors.accents[i]
end

-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 
-- Basic dash settings
theme.dash_bg         = colors.bg
theme.dash_widget_bg  = colors.bg_l0
theme.dash_widget_sel = colors.bg_l1
theme.dash_header_fg  = colors.main_accent
theme.dash_tab_fg     = colors.fg
theme.dash_tab_bg     = colors.bg_l0

-- Profile picture
theme.prof_name_fg    = colors.main_accent
theme.prof_pfp_bg     = colors.main_accent
theme.prof_title_fg   = colors.fg

-- Time and date
theme.timedate        = colors.main_accent

-- Music player
theme.mus_filter_1    = colors.bg_l3
theme.mus_filter_2    = colors.bg_l3
theme.mus_playing_fg  = colors.fg
theme.mus_control_bg  = colors.main_accent.."00"
theme.mus_control_fg  = colors.fg
theme.mus_bg          = colors.bg_l2

-- Finances
theme.cash_arccolors  = colors.accents
theme.cash_income_fg  = colors.green
theme.cash_expense_fg = colors.red
theme.cash_alttext_fg = colors.fg_alt
theme.cash_acct_name  = colors.fg_sub
theme.cash_action_btn = colors.bg_l2
theme.cash_budgetbar_bg = colors.bg_l1

-- Habits
theme.hab_freq        = colors.main_accent
theme.hab_uncheck_fg  = colors.fg
theme.hab_uncheck_bg  = colors.bg_l2
theme.hab_check_fg    = colors.fg
theme.hab_check_bg    = colors.main_accent
theme.hab_selected_bg = colors.red
theme.hab_selected_fg = colors.fg

-- Timewarrior
theme.timew_header_fg = colors.fg_sub
theme.timew_btn_bg    = colors.bg_l2

-- Fetch (unused)
theme.fetch_title     = colors.main_accent
theme.fetch_value     = colors.fg

-- Calendar
theme.cal_fg = colors.fg
theme.cal_bg = theme.dash_widget_bg
theme.cal_weekday_fg = colors.fg
theme.cal_header_fg = colors.fg
theme.cal_month_bg = theme.dash_widget_bg
theme.cal_focus_fg = colors.main_accent
theme.cal_focus_bg = theme.dash_widget_bg
theme.calendar_spacing = dpi(10)
theme.calendar_long_weekdays = true

-- Tasks
theme.task_prompt_contbg = theme.bg_l0
theme.task_prompt_textbg = theme.bg_l1
theme.task_due_fg        = colors.fg_sub
theme.task_overdue_fg    = colors.red
theme.task_next_fg       = colors.yellow
theme.task_selected_fg   = colors.main_accent
theme.task_scrollbar_bg  = colors.bg_l3
theme.task_scrollbar_fg  = colors.main_accent

-- Timewarrior
theme.timew_cal_heatmap_accent = colors.main_accent

-- █▄▄ ▄▀█ █▀█ 
-- █▄█ █▀█ █▀▄ 
theme.wibar_bg        = colors.bg
theme.wibar_fg        = colors.fg
theme.wibar_accent    = colors.main_accent
theme.wibar_focused   = theme.wibar_accent
theme.wibar_occupied  = colors.fg_alt
theme.wibar_empty     = colors.bg_l1
theme.wibar_bat_grn   = colors.green
theme.wibar_bat_nrml  = theme.wibar_fg
theme.wibar_bat_red   = colors.red
theme.wibar_slider_bg = colors.bg_l2
theme.wibar_bright_fg = theme.wibar_accent
theme.wibar_vol_fg    = theme.wibar_accent
theme.wibar_notif_fg  = theme.wibar_accent
theme.wibar_clock     = theme.wibar_fg
theme.wibar_launch_app    = theme.wibar_fg
theme.wibar_launch_dash   = theme.wibar_fg
theme.wibar_launch_ctrl   = theme.wibar_fg
theme.wibar_launch_theme  = theme.wibar_fg
theme.wibar_launch_hover  = colors.main_accent

-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░ 
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄ 
theme.ctrl_fg       = colors.fg
theme.ctrl_bg       = colors.bg_l0
theme.ctrl_host     = colors.fg_alt
theme.ctrl_uptime   = colors.fg_alt
theme.ctrl_link_fg  = colors.fg
theme.ctrl_link_bg  = colors.bg_l2
theme.ctrl_qa_btn_bg     = colors.bg_l2
theme.ctrl_lowerbar_bg   = colors.bg
theme.ctrl_powopt_bg     = colors.bg_l1
theme.ctrl_powopt_btn_fg = colors.fg

theme.ctrl_cpu_accent = colors.main_accent
theme.ctrl_ram_accent = colors.main_accent
theme.ctrl_hdd_accent = colors.main_accent

theme.ctrl_header_fg = colors.fg
theme.ctrl_pfp_bg   = colors.main_accent

theme.ctrl_fetch_accent = colors.main_accent
theme.ctrl_fetch_value  = colors.fg

theme.ctrl_stats_bg   = colors.bg_l2

-- ▀█▀ █░█ █▀▀ █▀▄▀█ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ░█░ █▀█ ██▄ █░▀░█ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 
theme.switcher_bg          = colors.bg_l0
theme.switcher_act_btn_bg  = colors.bg_l0
theme.switcher_opt_btn_bg  = colors.bg_l2
theme.switcher_lowbar_bg   = colors.bg
theme.switcher_header_fg   = colors.main_accent

-- █▄░█ █▀█ ▀█▀ █ █▀▀ █ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █░▀█ █▄█ ░█░ █ █▀░ █ █▄▄ █▀█ ░█░ █ █▄█ █░▀█ ▄█ 
theme.notif_bg          = colors.bg_l0
theme.notif_actions_bg  = colors.bg_l1
theme.notif_timeout_bg  = colors.bg_l1
theme.notif_dismiss_bg  = colors.bg_l0
theme.notification_spacing = dpi(10)
theme.notification_border_color = theme.notif_bg

-- █▀▄▀█ █ █▀ █▀▀ 
-- █░▀░█ █ ▄█ █▄▄ 
-- Layout list
theme.layout_bg = colors.bg_l0

-- Bling mstab
theme.mstab_bar_disable = false
theme.mstab_bar_ontop = false
theme.mstab_border_radius = 0
theme.mstab_tabbar_position = "top"
theme.mstab_tabbar_style = "default"
theme.mstab_master_position = "right"
theme.tabbed_bg_focus = colors.main_accent
theme.tabbed_fg_focus = colors.fg
theme.tabbar_bg_normal = colors.bg_l0
theme.tabbar_fg_normal = colors.bg_l3

-- Gaps
theme.useless_gap = dpi(7)

-- Borders
-- theme.border_width = dpi(3)
theme.border_width = dpi(0)
theme.border_color_active = colors.main_accent
theme.border_color_normal = colors.bg_l1

-- Corner radius
-- (not used for client rounding - used for rounding of other UI
-- components)
theme.border_radius = 10

-- Hotkeys
theme.hotkeys_modifiers_fg = colors.main_accent
theme.hotkeys_bg = colors.bg_l0
theme.hotkeys_fg = colors.fg
theme.hotkeys_border_width = dpi(0)
theme.hotkeys_group_margin = dpi(25)
theme.hotkeys_font = theme.font .. "13"
theme.hotkeys_description_font = theme.font .. "12"

-- Override default vars with vars defined in colorscheme
gears.table.crush(theme, colorscheme.colors) -- shouldn't be here
gears.table.crush(theme, colorscheme.override)

return theme
