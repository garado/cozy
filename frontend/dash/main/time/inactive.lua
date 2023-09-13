
-- █ █▄░█ ▄▀█ █▀▀ ▀█▀ █ █░█ █▀▀ 
-- █ █░▀█ █▀█ █▄▄ ░█░ █ ▀▄▀ ██▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local timew = require("backend.system.time")

local focus_time_today = ui.textbox({
  text  = "3h 45m",
  align = "center",
  font  = beautiful.font_reg_xxl,
})

local widget = wibox.widget({
  ui.textbox({
    text = "You've focused for",
    align = "center",
    color = beautiful.neutral[400],
  }),
  focus_time_today,
  ui.textbox({
    text = "today.",
    align = "center",
    color = beautiful.neutral[400],
  }),
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

timew:fetch_stats_today()
timew:connect_signal("stats::today::ready", function(_, time)
  focus_time_today:update_text(time)
end)

return widget
