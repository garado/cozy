
-- █▀█ █ █▀▀ █░█ ▀█▀ █░█ ▄▀█ █▄░█ █▀▄    █▀█ ▄▀█ █▄░█ █▀▀
-- █▀▄ █ █▄█ █▀█ ░█░ █▀█ █▀█ █░▀█ █▄▀    █▀▀ █▀█ █░▀█ ██▄

local wibox = require("wibox")
local gears = require("gears")
local box   = require("helpers").ui.create_boxed_widget
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local navbg = require("modules.keynav.navitem").Background

local PREV = -1;
local NEXT = 1;

local stats = require("apps.dash.time.targets")
local targets = require("apps.dash.time.targets")
local pane_widgets = { targets, stats }


-- █░█ █
-- █▄█ █

local function indicator()
  return wibox.widget({
    {
      bg = beautiful.bg_4,
      forced_width  = 5,
      forced_height = 5,
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
    self.children[self.cur_active].children[1].bg = beautiful.bg_4
    self.children[index].children[1].bg = beautiful.primary_0
    self.cur_active = index
  end,
  init = function(self)
    for _ = 1, #pane_widgets do
      self:add(indicator())
    end
    self:set_active(1)
  end
})
indicators:init()

local pane = wibox.widget({
  {
    {
      pane_widgets[1],
      forced_height = dpi(250),
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

local pane_cont = box(pane, dpi(0), dpi(310), beautiful.dash_widget_bg)
local navbox = navbg({ widget = pane_cont.children[1] })

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local cur_index = 1

--- Changes the widget displayed in the infobox.
-- @param direction NEXT or PREV (1 or -1)
local function switch_view(direction)
  if direction == NEXT then
    cur_index = cur_index + 1
    if cur_index > #pane_widgets then cur_index = 1 end
  elseif direction == PREV then
    cur_index = cur_index - 1
    if cur_index == 0 then cur_index = #pane_widgets end
  end

  indicators:set_active(cur_index)
  pane_widgets:set(pane_widgets[cur_index])
end

-- Keyboard navigation
local nav_pane = area({
  name = "timepane",
  circular = true,
  keys = {
    ["h"] = function() switch_view(PREV) end,
    ["l"] = function() switch_view(NEXT) end,
  },
  children = { navbox }
})

return function()
  return pane_cont, nav_pane
end
