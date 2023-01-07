
-- █▀▄ ▄▀█ █▀ █░█ ▀    ▄▀█ █▀▀ █▀▀ █▄░█ █▀▄ ▄▀█ 
-- █▄▀ █▀█ ▄█ █▀█ ▄    █▀█ █▄█ ██▄ █░▀█ █▄▀ █▀█ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")

local calendar    = require(... .. ".calendar")
local deadlines   = require(... .. ".deadlines")
local prompt      = require(... .. ".prompt")
local events, nav_events = require(... .. ".eventlist")()

-- Keynav
local nav_agenda = area:new({
  name = "agenda"
})
nav_agenda:append(nav_events)

local header = wibox.widget({
  markup = colorize("This week", beautiful.main_accent),
  font    = beautiful.font_name .. "17",
  --font = beautiful.alt_font_name .. "Light 30",
  align = "center",
  widget = wibox.widget.textbox,
})

local widget = wibox.widget({
  {
    -- header,
    calendar,
    deadlines,
    layout = wibox.layout.fixed.vertical,
  },
  {
    events,
    prompt,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.horizontal,
})

return function()
  return widget, nav_agenda
end
