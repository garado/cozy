
-- █▄▄ ▄▀█ █▀█
-- █▄█ █▀█ █▀▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

return function(s)
  -- Import modules
  local clock = require("ui.bar.clock")
  local battery = require("ui.bar.battery")
  local volume = require("ui.bar.volume")
  local brightness = require("ui.bar.brightness")
  -- local systray = require("ui.bar.systray")
  local layout, layout_popup = require("ui.bar.layout")()
  local taglist = require("ui.bar.taglist")
  local git = require("ui.bar.git_backup")
  local notif = require("ui.bar.notif")
  local app_launcher = require("ui.bar.app_launcher")
  local launchers = require("ui.bar.launchers")

  -- Assemble bar
  s.bar = awful.popup({
    screen = s,
    type = "dock",
    minimum_height = s.geometry.height,
    maximum_height = s.geometry.height,
    minimum_width = dpi(40),
    maximum_width = dpi(40),
    placement = function(c)
      awful.placement.left(c)
    end,
    widget = {
      {
        {
          layout = wibox.layout.align.vertical,
          expand = "none",
          {
            {
              app_launcher,
              launchers[1],
              launchers[2],
              launchers[3],
              git,
              spacing = dpi(15),
              layout = wibox.layout.fixed.vertical,
            },
            top = dpi(8),
            widget = wibox.container.margin,
          },
          taglist(s),
          {
            {
              brightness,
              volume,
              notif,
              layout,
              battery,
              clock,
              --systray,
              spacing = dpi(8),
              layout = wibox.layout.fixed.vertical,
            },
            bottom = dpi(6),
            widget = wibox.container.margin,
          },
        },
        left = dpi(3),
        right = dpi(3),
        widget = wibox.container.margin,
      },
      bg = beautiful.wibar_bg,
      widget = wibox.container.background,
    },
  })

  -- reserve screen space
  s.bar:struts({
    left = s.bar.maximum_width,
  })

  -- SETTINGS --
  -- Bar visibility
  local function remove_bar(c)
    if c.fullscreen or c.maximized then
      c.screen.bar.visible = false
    else
      c.screen.bar.visible = true
    end
  end

  -- i dont really understand this one
  local function add_bar(c)
    if c.fullscreen or c.maximized then
      c.screen.bar.visible = true
    end
  end

  --client.connect_signal("property::fullscreen", remove_bar)
  --client.connect_signal("request::unmanage", add_bar)
end
