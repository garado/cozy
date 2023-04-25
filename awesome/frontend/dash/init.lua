
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
local keynav    = require("modules.keynav")
local config    = require("cozyconf")


-- █▀ █ █▀▄ █▀▀ █▄▄ ▄▀█ █▀█ 
-- ▄█ █ █▄▀ ██▄ █▄█ █▀█ █▀▄ 

local main,   nav_main       = require(... .. ".main")()

local tablist   = { main,     }
local tabnames  = { "main",   }
local tab_icons = { "",      }
local navitems  = { nav_main, }

--- Display a specific tab on the dashboard
-- @param i   Index of tab to switch to.
local function switch_tab(i)
end

local distro_icon = ui.textbox({
  text  = config.distro_icon,
  color = beautiful.primary_0,
})

local pfp = wibox.widget({
  {
    image  = beautiful.pfp,
    resize = true,
    forced_height = dpi(28),
    forced_width  = dpi(28),
    widget = wibox.widget.imagebox,
  },
  bg     = beautiful.primary_0,
  shape  = gears.shape.circle,
  widget = wibox.container.background,
})

local tabbar = wibox.widget({
  {
    ui.place(pfp, { margins = { top = dpi(10) } }),
    nil,
    ui.place(distro_icon, { margins = { bottom = dpi(15) } }),
    layout = wibox.layout.align.vertical,
  },
  forced_width  = dpi(50),
  forced_height = dpi(1400),
  shape  = gears.shape.rect,
  bg     = beautiful.dash_tab_bg,
  widget = wibox.container.background,
})

-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

local dash = awful.popup({
  type = "splash",
  minimum_height = dpi(810),
  maximum_height = dpi(810),
  minimum_width  = dpi(1350),
  maximum_width  = dpi(1350),
  bg = beautiful.bg_0,
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = ({
    tabbar,
    {
      ui.place(main, { margins = dpi(5) }),
      widget = wibox.container.place,
    },
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

return function(_) return dash end
