
-- █▀▄ ▄▀█ █▀ █░█ ▀    ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
-- █▄▀ █▀█ ▄█ █▀█ ▄    █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")

local calendar = require(... .. ".calendar")
local prompt   = require(... .. ".prompt")
local infobox, nav_infobox  = require(... .. ".infobox")()
local events, nav_events    = require(... .. ".eventlist")()

-- Keynav
local nav_agenda = area:new({
  name = "agenda"
})
nav_agenda:append(nav_infobox)
nav_agenda:append(nav_events)

local main_contents = wibox.widget({
  {
    calendar,
    infobox,
    layout = wibox.layout.fixed.vertical,
  },
  {
    events,
    prompt,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.vertical,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return main_contents, nav_agenda
end
