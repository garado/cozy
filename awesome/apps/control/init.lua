
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░   █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄   █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local control = require("core.cozy.control")

local nav = require("modules.keynav.navigator")

local navigator, control_center
local power_confirm, power_opts, nav_power

local function control_center_contents()
  local uptime  = require("apps.control.uptime")
  local profile = require("apps.control.profile")
  local stats   = require("apps.control.stats")
  local fetch   = require("apps.control.fetch")
  local nav_picom, picom        = require("apps.control.picom")()
  local nav_qactions, qactions  = require("apps.control.quick_actions")()
  power_opts, power_confirm, nav_power = require("apps.control.power")()

  -- Import widgets
  navigator, _ = nav({
    root_children = {
      nav_picom,
      nav_qactions,
      nav_power
    }
  })

  local body = wibox.widget({
    {
      {
        {
          profile,
          fetch,
          layout = wibox.layout.fixed.horizontal,
        },
        widget = wibox.container.place,
      },
      stats,
      picom,
      qactions,
      -- links,
      spacing = dpi(25),
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(25),
    widget = wibox.container.margin,
  })

  local lower_tab = wibox.widget({
    {
      { -- left (uptime)
        {
          uptime,
          widget = wibox.container.place,
        },
        margins = dpi(15),
        widget = wibox.container.margin,
      }, -- end left
      nil,
      { -- right
        power_opts,
        layout = wibox.layout.fixed.horizontal,
      },
      forced_height = dpi(50),
      layout = wibox.layout.align.horizontal,
    },
    bg = beautiful.ctrl_lowerbar_bg,
    widget = wibox.container.background,
  })

  return wibox.widget({
    {
      {
        body,
        margins = {
          top = dpi(10),
          bottom = dpi(10),
        },
        widget = wibox.container.margin,
      },
      lower_tab,
      power_confirm,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    bg = beautiful.ctrl_bg,
  })
end

return function()
  local control_center_width = dpi(450)
  control_center = awful.popup ({
    type = "popup_menu",
    minimum_width = control_center_width,
    maximum_width = control_center_width,
    placement = awful.placement.centered,
    bg = beautiful.transparent,
    shape = gears.shape.rect,
    ontop = true,
    widget = control_center_contents(),
    visible = false,
  })

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  control:connect_signal("setstate::open", function()
    control:emit_signal("newstate::opened")
    control_center.visible = true
    navigator:start()
  end)

  control:connect_signal("setstate::close", function()
    navigator:stop()
    control_center.visible = false
    control:emit_signal("newstate::closed")
 	  collectgarbage("collect")
    power_confirm.visible = false
  end)

  control:connect_signal("power::confirm_toggle", function()
    if not power_confirm.visible then
      navigator:set_area("nav_power_opts")
      navigator.curr_area:iter(0)
    end
    power_confirm.visible = not power_confirm.visible
  end)

  control:connect_signal("power::confirm_on", function()
    power_confirm.visible = true
  end)

  control:connect_signal("redraw", function()
    control_center.widget = control_center_contents()
  end)

  return control_center
end
