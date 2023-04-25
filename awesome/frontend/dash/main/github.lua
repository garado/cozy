
-- █▀▀ █ ▀█▀ █░█ █░█ █▄▄ 
-- █▄█ █ ░█░ █▀█ █▄█ █▄█ 

local box   = require("utils.ui").dashbox
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("utils.ui").dpi

local gcw = require("modules.github")

local github = gcw({
  days  = 100,
  theme = "yoru",
  username = "garado",
  with_border = false,
})

local widget = wibox.widget({
  github,
  widget = wibox.container.place,
})

return box(widget, dpi(500), dpi(500), beautiful.dash_widget_bg)
