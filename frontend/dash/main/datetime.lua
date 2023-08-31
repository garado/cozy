
-- █▀▄ ▄▀█ ▀█▀ █▀▀ ▀█▀ █ █▀▄▀█ █▀▀ 
-- █▄▀ █▀█ ░█░ ██▄ ░█░ █ █░▀░█ ██▄ 

local ui = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local beautiful = require("beautiful")

local time = wibox.widget({
  format = "%I:%M",
  align  = "center",
  valign = "center",
  font   = beautiful.font_reg_xxl,
  widget = wibox.widget.textclock,
})

local date = wibox.widget({
  format = "%A %B %d",
  align  = "center",
  valign = "center",
  font   = beautiful.font_reg_s,
  widget = wibox.widget.textclock,
})

local datetime = wibox.widget({
  {
    time,
    fg = beautiful.primary[400],
    widget = wibox.container.background,
  },
  {
    date,
    fg = beautiful.neutral[100],
    forced_height = dpi(25),
    widget = wibox.container.background,
  },
  layout = wibox.layout.fixed.vertical,
})

return ui.dashbox_v2(datetime)
