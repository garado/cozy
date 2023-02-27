
-- █░░ █▀█ █▀▀ █▀█ 
-- █▄▄ █▄█ █▄█ █▄█ 

local wibox = require("wibox")
local gears = require("gears")
local colorize = require("helpers.ui").colorize_text
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

-- Profile picture
-- return wibox.widget({
--   {
--     {
--       forced_height = 20,
--       forced_width = 20,
--       image  = beautiful.pfp,
--       resize = true,
--       widget = wibox.widget.imagebox,
--     },
--     bg     = beautiful.primary_0,
--     shape  = gears.shape.circle,
--     widget = wibox.container.background,
--   },
--   widget = wibox.container.place,
-- })
