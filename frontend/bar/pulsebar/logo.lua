
-- █░░ █▀█ █▀▀ █▀█ 
-- █▄▄ █▄█ █▄█ █▄█ 

-- Pressing the logo launches the dashboard.

local wibox = require("wibox")
local ui   = require("utils.ui")
local beautiful = require("beautiful")
local dash = require("backend.cozy").dash
local conf = require("cozyconf")
local theme = require("theme.colorschemes."..conf.theme_name.."."..conf.theme_style)

local normal_fg    = theme.pulsebar_fg_l == "dark" and beautiful.primary[700] or beautiful.primary[500]
local mouseover_fg = theme.pulsebar_fg_l == "dark" and beautiful.primary[700] or beautiful.primary[400]

local logo = ui.textbox({
  text  = conf.distro_icon,
  font  = beautiful.font_reg_xs,
  color = normal_fg,
})

logo:connect_signal("mouse::enter", function()
  logo:update_color(mouseover_fg)
end)

logo:connect_signal("mouse::leave", function()
  logo:update_color(normal_fg)
end)

logo:connect_signal("button::press", function()
  dash:toggle()
end)

return wibox.container.place(logo)
