
-- █▀ █▄░█ ▄▀█ █▀▀ █▄▀ █▄▄ ▄▀█ █▀█
-- ▄█ █░▀█ █▀█ █▄▄ █░█ █▄█ █▀█ █▀▄

-- Show short updates about app processes at the bottom of the dash

local beautiful = require("beautiful")
local ui        = require("utils.ui")
local dpi       = ui.dpi
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local dash      = require("backend.cozy.dash")

local title = ui.textbox({
  text = "This is Primary 700.",
  font = beautiful.font_med_m,
  color = beautiful.primary[700]
})

local message = ui.textbox({
  text = "This is Pri 600. Background is Pri 100. Border is Pri 500.",
  color = beautiful.primary[600],
  height = dpi(30),
})

local widget    = wibox.widget({
  {
    {
      title,
      message,
      layout = wibox.layout.fixed.vertical,
    },
    right  = dpi(25),
    left   = dpi(20),
    top    = dpi(15),
    bottom = dpi(15),
    widget = wibox.container.margin,
  },
  bg = beautiful.primary[100],
  border_width = dpi(2),
  border_color = beautiful.primary[500],
  shape = ui.rrect(),
  widget = wibox.container.background,
})

function widget:set_title(text)
  title:update_text(text)
end

function widget:set_message(text)
  message:update_text(text)
end

local snackbar = awful.popup({
  minimum_height = dpi(68),
  maximum_height = dpi(68),
  minimum_width  = dpi(370),
  maximum_width  = dpi(370),
  x = 775,
  y = 850,
  type    = "splash",
  shape   = ui.rrect(),
  ontop   = true,
  visible = false,
  widget  = widget,
})

dash:connect_signal("snackbar::show", function(_, t, m)
  widget:set_title(t)
  widget:set_message(m)
  snackbar.visible = true

  gears.timer.start_new(2.5, function()
    snackbar.visible = false
  end)
end)

dash:connect_signal("snackbar::hide", function()
  snackbar.visible = false
end)
