
-- █▀▀ █ ▀█▀ █░█ █░█ █▄▄ 
-- █▄█ █ ░█░ █▀█ █▄█ █▄█ 

local box = require("helpers.ui").create_boxed_widget
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local github_contributions_widget = require("modules.github-contributions-widget.init")

local github = github_contributions_widget({
  with_border = false,
  days = 100,
  theme = "yoru",
  username = "garado"
})

local widget = wibox.widget({
  github,
  widget = wibox.container.place,
})

return box(widget, dpi(500), dpi(500), beautiful.dash_widget_bg)
-- return widget
