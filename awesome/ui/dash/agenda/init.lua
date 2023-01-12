
-- █▀▄ ▄▀█ █▀ █░█ ▀    ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
-- █▄▀ █▀█ ▄█ █▀█ ▄    █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local calpopup = require("core.cozy.calpopup")

local calendar, nav_gcal    = require(... .. ".calendar")()
local infobox, nav_infobox  = require(... .. ".infobox")()
local events, nav_events    = require(... .. ".eventlist")()

local nav_agenda = area({
  name = "agenda",
  keys = {
    ["A"] = function() calpopup:toggle() end,
  },
  children = {
    nav_gcal,
    nav_infobox,
    nav_events,
  },
})

local main_contents = wibox.widget({
  {
    calendar,
    infobox,
    layout = wibox.layout.fixed.vertical,
  },
  events,
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return main_contents, nav_agenda
end
