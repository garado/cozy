
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
local beautiful = require("beautiful")
local dashstate = require("backend.state.dash")
local config    = require("cozyconf")

-- Forward declarations
local content -- Container for tab contents

-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

-- Enums for tab names
local MAIN = 1
local SETTINGS = 2

-- Load tabs
local main,     nav_main      = require(... .. ".main")()
local settings, nav_settings  = require(... .. ".settings")()

local tablist   = { main,     settings,      }
local tabnames  = { "main",   "settings",    }
local tab_icons = { "",      "",           }
local navitems  = { nav_main, nav_settings , }

local tab_buttons = wibox.widget({
  layout  = wibox.layout.fixed.vertical,
  -------
  add_tab = function(self, i)
    local btn = wibox.widget({
      {
        ui.textbox({
          text = tab_icons[i]
        }),
        left = dpi(2),
        widget = wibox.container.margin,
      },
      bg = beautiful.neutral[800],
      forced_height = dpi(50),
      widget = wibox.container.background,
      ------
      tab_enum = i,
      bg_color = beautiful.neutral[800],
      mo_color = beautiful.neutral[700],
      select = function(self)
        self.children[1].color = beautiful.fg
      end,
      deselect = function(self)
        self.children[1].color = nil
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

for i = 1, #tablist, 1 do
  tab_buttons:add_tab(i)
end

--- Pressing a tab button emits tab::set signal throughout dash
-- Update dash contents and UI of selected tab
dashstate:connect_signal("tab::set", function(_, tab_enum)
  -- Tab button UI
  for i = 1, #tab_buttons.children do
    if tab_buttons.children[i].tab_enum == tab_enum then
      tab_buttons.children[i]:select()
    else
      tab_buttons.children[i]:deselect()
    end
  end

  -- Dash contents
  content:update_contents(tablist[tab_enum])
end)

local distro_icon = ui.textbox({
  text  = config.distro_icon,
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

content = wibox.widget({
  main,
  top    = dpi(0),
  bottom = dpi(5),
  left   = dpi(25),
  right  = dpi(5),
  widget = wibox.container.margin,
  ------
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
  dashstate:emit_signal("newstate::opened")
end)

dashstate:connect_signal("setstate::close", function()
  dash.visible = false
  dashstate:emit_signal("newstate::closed")
end)

awesome.connect_signal("theme::switch", function()
end)

dashstate:set_tab(MAIN)

return function(_) return dash end
