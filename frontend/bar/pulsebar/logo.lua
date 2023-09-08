
-- █░░ █▀█ █▀▀ █▀█ 
-- █▄▄ █▄█ █▄█ █▄█ 

-- Pressing the logo launches the dashboard.

local wibox = require("wibox")
local ui   = require("utils.ui")
local beautiful = require("beautiful")
local dash = require("backend.cozy.dash")
local conf = require("cozyconf")

local logo = ui.textbox({
  text = conf.distro_icon,
  font = beautiful.font_reg_xs,
  color = beautiful.primary[400],
})

logo:connect_signal("mouse::enter", function()
  logo:update_color(beautiful.primary[700])
end)

logo:connect_signal("mouse::leave", function()
  logo:update_color(beautiful.primary[400])
end)

logo:connect_signal("button::press", function()
  dash:toggle()
end)

return wibox.widget({
  logo,
  widget = wibox.container.place,
})
