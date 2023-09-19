
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

-- This file implements the wrapper for the dashboard and is
-- responsible for managing tab switching and responding to
-- open/close signals.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ui  = require("utils.ui")
local dpi = require("utils.ui").dpi
local keynav = require("modules.keynav")
local beautiful = require("beautiful")
local manager = require("backend.cozy").dash
local config = require("cozyconf")

local navigator, nav_root = keynav.navigator()
local content

require(... .. ".snackbar")

local TAB_ICONS = {
  ["main"]     = "",
  ["task"]     = "󰄴",
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
    manager:set_tab(i)
  end
end
nav_root.keys = root_keys

-- Generate tab sidebar
local tab_buttons = wibox.widget({
  layout  = wibox.layout.fixed.vertical,

  -- @param i A tab enum
  add_tab = function(self, i)
    local btn = wibox.widget({
      {
        ui.textbox({
          text  = tab_icons[i],
          align = "center",
        }),
        left   = dpi(2),
        widget = wibox.container.margin,
      },
      bg = beautiful.primary[800],
      forced_height = dpi(50),
      widget = wibox.container.background,
      ------
      tab_enum = i,
      bg_color = beautiful.neutral[800],
      mo_color = beautiful.neutral[700],
      select = function(_self)
        -- Margin
        _self.children[1].color = beautiful.neutral[100]

        -- Icon color
        _self.children[1].widget:update_color(beautiful.neutral[100])

        _self.bg_color = beautiful.neutral[600]
        _self.mo_color = beautiful.neutral[500]
        _self.bg = _self.bg_color
      end,
      deselect = function(_self)
        -- Margin
        _self.children[1].color = nil

        -- Icon color
        _self.children[1].widget:update_color(beautiful.neutral[500])

        _self.bg_color = beautiful.neutral[800]
        _self.mo_color = beautiful.neutral[700]
        _self.bg = _self.bg_color
      end,
    })

    btn:connect_signal("mouse::enter", function()
      btn.bg = btn.mo_color
    end)

    btn:connect_signal("mouse::leave", function()
      btn.bg = btn.bg_color
    end)

    btn:connect_signal("button::press", function()
      manager:set_tab(btn.tab_enum)
    end)

    self:add(btn)
  end
})

for i = 1, #tab_list do
  tab_buttons:add_tab(i)
end

-- Logic for switching tabs
manager:connect_signal("tab::set", function(_, tab_enum)
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
    { -- Profile picture
      {
        {
          {
            image  = beautiful.pfp,
            resize = true,
            forced_height = dpi(28),
            forced_width  = dpi(28),
            widget = wibox.widget.imagebox,
          },
          bg     = beautiful.primary[300],
          shape  = gears.shape.circle,
          widget = wibox.container.background,
        },
        top = dpi(10),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place,
    },
    tab_buttons,
    { -- Distro icon
      {
        ui.textbox({
          text  = config.distro_icon,
          align = "center",
          color = beautiful.primary[300],
        }),
        widget = wibox.container.place,
      },
      bottom = dpi(15),
      widget = wibox.container.margin,
    },
    expand = "none",
    layout = wibox.layout.align.vertical,
  },
  forced_width  = dpi(50),
  forced_height = dpi(1400),
  shape  = gears.shape.rect,
  bg     = beautiful.neutral[800],
  widget = wibox.container.background,
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
  shape = ui.rrect(),
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = ({
    {
      sidebar,
      content,
      layout = wibox.layout.align.horizontal,
    },
    bg = beautiful.neutral[900],
    widget = wibox.container.background,
  }),
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

manager:connect_signal("setstate::open", function()
  dash.screen = awful.screen.focused()
  dash.visible = true
  navigator:start()
  manager:emit_signal("newstate::opened")
end)

manager:connect_signal("setstate::close", function()
  dash.visible = false
  navigator:stop()
  manager:emit_signal("newstate::closed")
  manager:emit_signal("snackbar::hide")
end)

awesome.connect_signal("theme::reload", function()
  manager:set_tab(manager.curtab)
end)

manager:set_tab(1)
return function(_) return dash end
