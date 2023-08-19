
-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local wibox = require("wibox")

return wibox.widget({
  {
    {
      image  = beautiful.pfp,
      resize = true,
      valign = "center",
      align  = "center",
      forced_height = dpi(80),
      forced_width  = dpi(80),
      clip_shape    = gears.shape.circle,
      widget = wibox.widget.imagebox,
    },
    bg     = beautiful.primary[300],
    shape  = gears.shape.circle,
    widget = wibox.container.background,
  },
  widget = wibox.container.place,
})
