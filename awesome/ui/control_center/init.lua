
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░   █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄   █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- For navigation
local Box = require("ui.nav.box")
local nav = require("ui.nav.navigate")
nav:set_rules({
  qactions = {
    j = 5,
    k = -5,
    --j = nav:get_index() > 5 and 1 or 5,
    --k = nav:get_index() < 5 and -5 or 1
  },
  links = {
    j = 2,
    k = -2,
    --j = nav:get_index() > 4 and 1 or 2,
    --k = nav:get_index() < 3 and -1 or -2,
  }
})

local nav_root = Box:new({
  name = "root",
  circular = true,
})

-- Import widgets
-- local profile = require("ui.control_center.profile")
local uptime = require("ui.control_center.uptime")

local _qa = require("ui.control_center.quick_actions")
local qactions = _qa.widget
local nav_qactions = _qa.nav

local _links = require("ui.control_center.links")
local links = _links.widget
local nav_links = _links.nav

local power_opts, power_confirm, nav_power
power_opts, power_confirm, nav_power = require("ui.control_center.power")()

nav_root:append(nav_qactions)
nav_root:append(nav_links)
nav_root:append(nav_power)

return function()
  local body = wibox.widget({
    {
      qactions,
      links,
      spacing = dpi(20),
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
      }, -- end right
      forced_height = dpi(50),
      layout = wibox.layout.align.horizontal,
    },
    bg = beautiful.ctrl_lowerbar_bg,
    widget = wibox.container.background,
  })

  -- assemble the control center
  power_confirm.visible = false
  local control_center_contents = wibox.widget({
    {
      body,
      lower_tab,
      power_confirm,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    bg = beautiful.ctrl_bg,
  })

  local control_center_width = dpi(500)
  local control_center = awful.popup ({
    type = "popup_menu",
    minimum_width = control_center_width,
    maximum_width = control_center_width,
    placement = awful.placement.centered,
    bg = beautiful.transparent,
    shape = gears.shape.rect,
    ontop = true,
    widget = control_center_contents,
    visible = false,
  })

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  awesome.connect_signal("control_center::toggle", function()
    control_center.visible = not control_center.visible
    if control_center.visible then
      require("ui.shared").close_other_popups("control_center")
      nav:start(nav_root)
    else
      nav:stop()
      power_confirm.visible = false
    end
  end)

  awesome.connect_signal("control_center::open", function()
    control_center.visible = true
  end)

  awesome.connect_signal("control_center::close", function()
    control_center.visible = false
  end)

  awesome.connect_signal("ctrl::power_confirm_toggle", function()
    power_confirm.visible = not power_confirm.visible
  end)

  awesome.connect_signal("ctrl::power_confirm_on", function()
    power_confirm.visible = true
  end)

  return control_center
end

