
-- █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▄▄ █▀█ ▀▄▀ 
-- ██▄ ▀▄▀ ██▄ █░▀█ ░█░ █▄█ █▄█ █░█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local eventbox = wibox.widget({
  layout = wibox.layout.manual,
  -------
  add_event = function(self, event)
  end
})

return eventbox
