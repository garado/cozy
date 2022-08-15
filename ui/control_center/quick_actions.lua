
-- █▀█ █░█ █ █▀▀ █▄▀   ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ▀▀█ █▄█ █ █▄▄ █░█   █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")
local widgets = require("ui.widgets")

local function create_quick_action(icon, name, msg, cmd)
  local quick_action = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.wibar_bg,
    animate_size = false,
    size = 12,
    on_release = function()
      naughty.notification {
        app_name = "Quick actions",
        title = name,
        message = cmd,
      }
    end,
  })
  return wibox.widget({
    quick_action,
    widget = wibox.container.place,
  })
end

local widget = wibox.widget({
  create_quick_action("calc", "calc", "", ""),
  create_quick_action("conservation mode", "Conservation mode", "", ""),
  create_quick_action("airplane mode", "Airplane mode", "", ""),
  create_quick_action("", "Rotate", "", ""),
  layout = wibox.layout.fixed.vertical,
})

return widget
