
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █▀█ █░░   █▀▀ █▀▀ █▄░█ ▀█▀ █▀▀ █▀█
-- █▄▄ █▄█ █░▀█ ░█░ █▀▄ █▄█ █▄▄   █▄▄ ██▄ █░▀█ ░█░ ██▄ █▀▄

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local keygrabber = require("awful.keygrabber")
local naughty = require("naughty")

-- import widgets
local profile = require("ui.control_center.profile")
local quick_actions = require("ui.control_center.quick_actions") local uptime = require("ui.control_center.uptime")
local power_options = require("ui.control_center.power_options")
local links = require("ui.control_center.links")

return function()
  -- assemble the control center
  local control_center_contents = wibox.widget({
    {
        { -- body
          {
            quick_actions,
            links,
            spacing = dpi(20),
            layout = wibox.layout.fixed.vertical,
          },
          margins = dpi(25),
          widget = wibox.container.margin,
        }, -- end body
        { -- lower tab
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
              power_options,
              layout = wibox.layout.fixed.horizontal,
            }, -- end right
            forced_height = dpi(50),
            layout = wibox.layout.align.horizontal,
          },
          bg = beautiful.ctrl_lowerbar_bg,
          widget = wibox.container.background,
        }, -- end lower tab
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
    visible = false,
    widget = control_center_contents,
  })

  -- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
  -- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
  awesome.connect_signal("control_center::toggle", function()
    control_center.visible = not control_center.visible
    if control_center.visible then
      require("ui.shared").close_other_popups("control_center")
    end
  end)

  awesome.connect_signal("control_center::open", function()
    control_center.visible = true
  end)

  awesome.connect_signal("control_center::close", function()
    control_center.visible = false
  end)


  return control_center
end

