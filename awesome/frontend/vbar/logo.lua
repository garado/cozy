
local wibox = require("wibox")
local colorize = require("utils.ui").colorize
local beautiful = require("beautiful")

-- Arch logo
return wibox.widget({
  {
    markup = colorize("", beautiful.primary_0),
    valign = "center",
    align  = "center",
    font   = beautiful.font_reg_xs,
    widget = wibox.widget.textbox,
  },
  widget = wibox.container.place,
})
