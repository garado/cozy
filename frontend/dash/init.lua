
-- █▀▄ ▄▀█ █▀ █░█ █▄▄ █▀█ ▄▀█ █▀█ █▀▄ 
-- █▄▀ █▀█ ▄█ █▀█ █▄█ █▄█ █▀█ █▀▄ █▄▀ 

-- This file implements the wrapper for the dashboard and is
-- responsible for managing tab switching and responding to
-- open/close signals.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ui    = require("utils.ui")
local dpi   = require("utils.ui").dpi
local keynav = require("modules.keynav")
local beautiful = require("beautiful")
local dashstate = require("backend.cozy.dash")
local config    = require("cozyconf")

-- Forward declarations
local content -- Container for tab contents

local navigator, nav_root = keynav.navigator()

-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

-- Enums for tab names
local MAIN     = 1
local TASK     = 2
local LEDGER   = 3
local CALENDAR = 4
local GOALS    = 5
local SETTINGS = 6

-- Set up tab info
local main,     nav_main     = require(... .. ".main")()
local task,     nav_task     = require(... .. ".task")()
local ledger,   nav_ledger   = require(... .. ".ledger")()
local calendar, nav_calendar = require(... .. ".calendar")()
local goals,    nav_goals    = require(... .. ".goals-habits")()
local settings, nav_settings = require(... .. ".settings")()

local tablist   = { main,     task,     ledger,     calendar,     goals,      settings,     }
local tabnames  = { "main",   "task",   "ledger",   "calendar",   "goals",    "settings",   }
local tab_icons = { "",      "",      "",        "",          "󰓾",        "",          }
local navitems  = { nav_main, nav_task, nav_ledger, nav_calendar, nav_goals,  nav_settings, }

-- Pressing number keys switches tabs
local root_keys = {}
for i = 1, #tablist do
  root_keys[tostring(i)] = function()
    dashstate:set_tab(i)
  end
end
nav_root.keys = root_keys

-- Build tab sidebar
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
      forced_height = dpi(50),
      bg     = beautiful.primary[800],
      widget = wibox.container.background,
      ------
      tab_enum = i,
      bg_color = beautiful.neutral[800],
      mo_color = beautiful.neutral[700],
      select = function(_self)
        -- Margin
        _self.children[1].color = beautiful.fg

        -- Icon color
        _self.children[1].widget:update_color(beautiful.fg)

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
      dashstate:set_tab(btn.tab_enum)
    end)

    self:add(btn)
  end
})

for i = 1, #tablist do
  tab_buttons:add_tab(i)
end

dashstate:connect_signal("tab::set", function(_, tab_enum)
  -- Update sidebar
  for i = 1, #tab_buttons.children do
    if tab_buttons.children[i].tab_enum == tab_enum then
      tab_buttons.children[i]:select()
    else
      tab_buttons.children[i]:deselect()
    end
  end

  content:update_contents(tablist[tab_enum])

  -- Update keynav areas
  if navitems[tab_enum] and not nav_root:contains_area(navitems[tab_enum]) then
    nav_root:clear()
    nav_root:append(navitems[tab_enum])
    nav_root:verify_nav_references()
  end
end)

-- Building the rest of the sidebar

local distro_icon = ui.textbox({
  text  = config.distro_icon,
  align = "center",
  color = beautiful.primary[300],
})

local pfp = wibox.widget({
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
})

local sidebar = wibox.widget({
  {
    ui.place(pfp, { margins = { top = dpi(10) } }),
    tab_buttons,
    ui.place(distro_icon, { margins = { bottom = dpi(15) } }),
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
  main,
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
    sidebar,
    content,
    layout = wibox.layout.align.horizontal,
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
end)

dashstate:set_tab(MAIN)
return function(_) return dash end
