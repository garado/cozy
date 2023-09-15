
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

-- This file implements the wrapper for the dashboard and is
-- responsible for managing tab switching and responding to
-- open/close signals.

local awful = require("awful")
local wibox = require("wibox")
local ui  = require("utils.ui")
local dpi = require("utils.ui").dpi
local keynav = require("modules.keynav")
local beautiful = require("beautiful")
local dashstate = require("backend.cozy.dash")
local config = require("cozyconf")
local triangles = require("frontend.widget.yorha.triangles")

local navigator, nav_root = keynav.navigator()
local content

require(... .. ".snackbar")

local TAB_ICONS = {
  ["main"]     = "",
  ["task"]     = "",
  ["ledger"]   = "",
  ["calendar"] = "",
  ["goals"]    = "",
}

local tab_list  = {}
local tab_nav   = {}
local tab_icons = {}

-- Only require the tabs specified in config
for _, tab in ipairs(config.tabs) do
  local _tab_content, _tab_nav = require(... .. "." .. tab)()
  tab_icons[#tab_icons+1] = TAB_ICONS[tab]
  tab_list[#tab_list+1] = _tab_content
  tab_nav[#tab_nav+1] = _tab_nav
end

-- Generate keybinds for switching tabs (number keys)
local root_keys = {}
for i = 1, #tab_list do
  root_keys[tostring(i)] = function()
    dashstate:set_tab(i)
  end
end
nav_root.keys = root_keys

local function gen_tab_button(i)
  local icon_text = ui.textbox({
    text = tab_icons[i],
    color = beautiful.neutral[900],
    align = "center",
  })

  local icon = wibox.widget({
    {
      icon_text,
      margins = dpi(3),
      widget = wibox.container.margin,
    },
    forced_width  = dpi(25),
    forced_height = dpi(25),
    bg = beautiful.neutral[100],
    widget = wibox.container.background,
  })

  local tabtext = ui.textbox({
    text = config.tabs[i]:upper(),
    align = "center",
  })

  local c = wibox.widget({
    {
      {
        {
          icon,
          widget = wibox.container.place,
        },
        tabtext,
        spacing = dpi(6),
        layout = wibox.layout.fixed.horizontal,
      },
      top    = dpi(5),
      bottom = dpi(5),
      left   = dpi(5),
      right  = dpi(30),
      widget = wibox.container.margin,
    },
    bg = beautiful.neutral[600],
    widget = wibox.container.background,
  })

  local widget = wibox.widget({
    ui.vpad(dpi(5)),
    c,
    {
      forced_height = dpi(25),
      bg = beautiful.neutral[100],
      widget = wibox.container.background,
    },
    forced_height = dpi(43),
    layout = wibox.layout.fixed.vertical,
  })

  widget.tab_enum = i

  function widget:deselect()
    icon.bg = beautiful.neutral[100]
    icon_text:update_color(beautiful.neutral[900])
    tabtext:update_color(beautiful.neutral[100])
    c.bg = beautiful.neutral[500]
    widget.children[3].bg = beautiful.neutral[900]
  end

  function widget:select()
    icon.bg = beautiful.neutral[900]
    icon_text:update_color(beautiful.neutral[100])
    tabtext:update_color(beautiful.neutral[900])
    c.bg = beautiful.neutral[100]
    widget.children[3].bg = beautiful.neutral[100]
  end

  widget:connect_signal("button::press", function()
    dashstate:set_tab(widget.tab_enum)
  end)

  return widget
end

-- Generate tab sidebar
local tab_buttons = wibox.widget({
  spacing = dpi(30),
  layout  = wibox.layout.fixed.horizontal,
})

for i = 1, #tab_list do
  tab_buttons:add(gen_tab_button(i))
end

-- Logic for switching tabs
dashstate:connect_signal("tab::set", function(_, tab_enum)
  -- Update sidebar
  for i = 1, #tab_buttons.children do
    if tab_buttons.children[i].tab_enum == tab_enum then
      tab_buttons.children[i]:select()
    else
      tab_buttons.children[i]:deselect()
    end
  end

  content:update_contents(tab_list[tab_enum])

  -- Update keynav areas
  if tab_nav[tab_enum] and not nav_root:contains_area(tab_nav[tab_enum].name) then
    nav_root:clear()
    nav_root:append(tab_nav[tab_enum])
    nav_root:verify_nav_references()
  end
end)

-- Building the rest of the sidebar
local sidebar = wibox.widget({
  {
    {
      ui.textbox({
        text = require("cozyconf").distro_icon,
        align = "center",
      }),
      left = dpi(10),
      widget = wibox.container.margin,
    },
    {
      {
        tab_buttons,
        widget = wibox.container.place,
      },
      top = dpi(4),
      widget = wibox.container.margin,
    },
    nil,
    layout = wibox.layout.align.horizontal,
  },
  {
    {
      color = beautiful.neutral[100],
      border_width = 0,
      thickness = dpi(4),
      forced_height = dpi(2),
      widget = wibox.widget.separator,
    },
    {
      triangles,
      forced_height = dpi(40),
      widget = wibox.container.place,
    },
    layout = wibox.layout.fixed.vertical,
  },
  layout = wibox.layout.fixed.vertical,
})

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- Container for dash contents
content = wibox.widget({
  margins = dpi(15),
  widget  = wibox.container.margin,
  update_contents = function(self, new_content)
    self.widget = new_content
  end
})

local dash = awful.popup({
  type = "splash",
  minimum_height = dpi(810),
  maximum_height = dpi(810),
  minimum_width  = dpi(1350),
  maximum_width  = dpi(1350),
  bg = beautiful.neutral[900],
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = ({
    {
      {
        sidebar,
        forced_height = dpi(70),
        widget = wibox.container.place,
      },
      content,
      layout = wibox.layout.fixed.vertical,
    },
    bg = beautiful.neutral[900],
    widget = wibox.container.background,
  }),
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

dashstate:connect_signal("setstate::open", function()
  dash.visible = true
  navigator:start()
  dashstate:emit_signal("newstate::opened")
end)

dashstate:connect_signal("setstate::close", function()
  dash.visible = false
  navigator:stop()
  dashstate:emit_signal("newstate::closed")
  dashstate:emit_signal("snackbar::hide")
end)

awesome.connect_signal("theme::reload", function()
  dashstate:set_tab(dashstate.curtab)
end)

dashstate:set_tab(1)
return function(_) return dash end
