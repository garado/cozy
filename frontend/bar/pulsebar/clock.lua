
-- █▀▀ █░░ █▀█ █▀▀ █▄▀ 
-- █▄▄ █▄▄ █▄█ █▄▄ █░█ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local conf = require("cozyconf")
local theme = require("theme.colorschemes."..conf.theme_name.."."..conf.theme_style)

local clock = wibox.widget({
  format  = "%A %d %b %H:%M",
  align   = "center",
  valign  = "center",
  font    = beautiful.font_reg_xs,
  widget  = wibox.widget.textclock,
})

local clock_color = wibox.container.background()
clock_color:set_widget(clock)
clock_color:set_fg(theme.pulsebar_fg_m == "dark" and beautiful.neutral[900] or beautiful.neutral[100])

return clock_color
