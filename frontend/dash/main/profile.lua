-- █▀█ █▀█ █▀█ █▀▀ █ █░░ █▀▀
-- █▀▀ █▀▄ █▄█ █▀░ █ █▄▄ ██▄

local ui        = require("utils.ui")
local dpi       = ui.dpi
local gears     = require("gears")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dash      = require("backend.cozy.dash")
local conf      = require("cozyconf")

local math = math

local pfp       = wibox.widget({
  {
    {
      image         = beautiful.pfp,
      resize        = true,
      forced_height = dpi(110),
      forced_width  = dpi(110),
      widget        = wibox.widget.imagebox,
    },
    widget = wibox.container.place,
  },
  bg     = beautiful.primary[300],
  shape  = gears.shape.circle,
  widget = wibox.container.background,
})

local title = ui.textbox({
  text = "Vim enthusiast",
  align = "center",
  color = beautiful.neutral[300],
})

dash:connect_signal("setstate::close", function()
  local new_title = math.random(1, #conf.titles)
  title:update_text(conf.titles[new_title])
end)

local widget = wibox.widget({
  pfp,
  {
    ui.textbox({
      text = "Alexis G.",
      font = beautiful.font_med_m,
      align = "center",
    }),
    title,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
})

return wibox.widget({
  widget,
  widget = wibox.container.place,
})
