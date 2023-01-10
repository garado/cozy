
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

local weather   = require("ui.dash.agenda.weather")
local deadlines = require("ui.dash.agenda.deadlines")
local goals     = require("ui.dash.agenda.goals")

local infobox_widgets = { weather, deadlines, goals }

local NEXT = 1
local PREV = -1

-- █░█ █
-- █▄█ █

local function indicator()
  return wibox.widget({
    {
      bg = beautiful.bg_l3,
      forced_width  = 6,
      forced_height = 6,
      shape = gears.shape.circle,
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
  })
end

local indicators = wibox.widget({
  spacing = dpi(6),
  layout  = wibox.layout.fixed.horizontal,
  -----
  cur_active = 1,
  set_active = function(self, index)
    self.children[self.cur_active].children[1].bg = beautiful.bg_l3
    self.children[index].children[1].bg = beautiful.main_accent
    self.cur_active = index
  end,
  init = function(self)
    for _ = 1, #infobox_widgets do
      self:add(indicator())
    end
    self:set_active(1)
  end
})
indicators:init()

local infobox = wibox.widget({
  {
    {
      infobox_widgets[1],
      forced_height = dpi(300),
      widget = wibox.container.place,
    },
    wibox.widget({
      indicators,
      widget = wibox.container.place,
    }),
    layout = wibox.layout.fixed.vertical,
  },
  margins = dpi(5),
  widget = wibox.container.margin,
  -----
  set = function(self, widget)
    self.children[1].children[1].widget = widget
  end,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local cur_index = 1

--- Changes the widget displayed in the infobox.
-- @param direction NEXT or PREV (1 or -1)
local function switch_view(direction)
  if direction == NEXT then
    cur_index = cur_index + 1
    if cur_index > #infobox_widgets then cur_index = 1 end
  elseif direction == PREV then
    cur_index = cur_index - 1
    if cur_index == 0 then cur_index = #infobox_widgets end
  end

  indicators:set_active(cur_index)
  infobox:set(infobox_widgets[cur_index])
end

-- Keyboard navigation
local nav_infobox = area:new({
  name = "infobox",
  circular = true,
  keys = {
    ["h"] = { f = function() switch_view(PREV) end },
    ["l"] = { f = function() switch_view(NEXT) end },
  },
})

local infobox_cont = box(infobox, dpi(0), dpi(350), beautiful.dash_widget_bg)

local navbox = Background:new(infobox_cont.children[1])
nav_infobox:append(navbox)

return function()
  return infobox_cont, nav_infobox
end
