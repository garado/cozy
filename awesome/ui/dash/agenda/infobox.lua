
-- █ █▄░█ █▀▀ █▀█ █▄▄ █▀█ ▀▄▀ 
-- █ █░▀█ █▀░ █▄█ █▄█ █▄█ █░█ 

-- Box at the bottom left of the agenda tab.
-- Contains multiple tabs to show weather and deadlines. (maybe goals in the future)

local wibox = require("wibox")
local gears = require("gears")
local box   = require("helpers").ui.create_boxed_widget
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local Background = require("modules.keynav.navitem").Background

local deadlines = require("ui.dash.agenda.deadlines")
local weather   = require("ui.dash.agenda.weather")

-- █░█ █ 
-- █▄█ █ 

--- Creates a single indicator widget.
local function indicator(color)
  color = color or beautiful.fg
  return wibox.widget({
    {
      bg = color,
      forced_width  = 6,
      forced_height = 6,
      shape = gears.shape.circle,
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
  })
end

local indicator_container = wibox.widget({
  indicator(beautiful.main_accent),
  indicator(),
  spacing = dpi(6),
  layout = wibox.layout.fixed.horizontal,
})

local infobox = wibox.widget({
  {
    deadlines,
    nil,
    wibox.widget({
      indicator_container,
      widget = wibox.container.place,
    }),
    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(20),
  widget = wibox.container.margin,
})

local infobox_cont = box(infobox, dpi(0), dpi(350), beautiful.dash_widget_bg)

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local infobox_widgets = { deadlines, weather }

local cur_infobox_index = 1

--- Changes the widget displayed in the infobox.
-- @param direction An integer -1 or 1. -1 means cycle left, 1 means cycle right.
local function switch_view(direction)
  -- Update old indicator
  local oldindicator = indicator_container.children[cur_infobox_index].children[1]
  oldindicator.bg = beautiful.fg

  -- Get new infobox index
  if direction > 0 then
    cur_infobox_index = cur_infobox_index + 1
    if cur_infobox_index > #infobox_widgets then cur_infobox_index = 1 end
  else
    cur_infobox_index = cur_infobox_index - 1
    if cur_infobox_index == 0 then cur_infobox_index = #infobox_widgets end
  end

  -- Change widget and indicator
  infobox.children[1]:set(1, infobox_widgets[cur_infobox_index])
  local curindicator = indicator_container.children[cur_infobox_index].children[1]
  curindicator.bg = beautiful.main_accent
end

-- Keyboard navigation
local nav_infobox = area:new({
  name = "infobox",
  circular = true,
  keys = {
    ["h"] = {["function"] = switch_view, ["args"] = -1},
    ["l"] = {["function"] = switch_view, ["args"] = 1},
  },
})

local navbox = Background:new(infobox_cont.children[1])
nav_infobox:append(navbox)

return function()
  return infobox_cont, nav_infobox
end
