
-- █▀▀ █░░ █▀█ █▀▀ █▄▀ 
-- █▄▄ █▄▄ █▄█ █▄▄ █░█ 

local wibox = require("wibox")
local beautiful = require("beautiful")

return function(format)
  local clock = wibox.widget({
    format  = format,
    align   = "center",
    valign  = "center",
    font    = beautiful.font_reg_xs,
    widget  = wibox.widget.textclock,
  })

  local clock_color = wibox.container.background()
  clock_color:set_widget(clock)
  clock_color:set_fg(beautiful.neutral[100])

  return clock_color
end
