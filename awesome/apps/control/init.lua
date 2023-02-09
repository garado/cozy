
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░   █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄   █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local awful   = require("awful")
local gears   = require("gears")
local wibox   = require("wibox")
local control = require("core.cozy.control")
local keynav  = require("modules.keynav")

local uptime  = require(... .. ".uptime")
local profile = require(... .. ".profile")
local stats   = require(... .. ".stats")
local fetch   = require(... .. ".fetch")
local picom, nav_picom = require(... .. ".picom")()
local qactions, nav_qactions  = require(... .. ".quick_actions")()
local power_opts, power_confirm, nav_power = require(... .. ".power")()

local control_center

local navigator, _ = keynav.navigator({
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
    spacing = dpi(25),
    layout  = wibox.layout.fixed.vertical,
  },
  margins = dpi(25),
  widget  = wibox.container.margin,
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

local contents = wibox.widget({
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

local width = dpi(450)
control_center = awful.popup ({
  minimum_width = width,
  maximum_width = width,
  placement     = awful.placement.centered,
  type    = "popup_menu",
  bg      = beautiful.transparent,
  shape   = gears.shape.rect,
  ontop   = true,
  widget  = contents,
  visible = false,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

control:connect_signal("setstate::open", function()
  control_center.visible = true
  navigator:start()
end)

control:connect_signal("setstate::close", function()
  navigator:stop()
  control_center.visible = false
  power_confirm.visible  = false
  collectgarbage("collect")
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

return function()
  return control_center
end
