
-- █░█ █▄▄ ▄▀█ █▀█ 
-- ▀▄▀ █▄█ █▀█ █▀▄ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local clock      = require(... .. ".clock")
local battery    = require(... .. ".battery")
local volume     = require(... .. ".volume")
local brightness = require(... .. ".brightness")
local taglist = require(... .. ".taglist")
local git     = require(... .. ".git_backup")
local notif   = require(... .. ".notif")
local app_launcher = require(... .. ".app_launcher")
local launchers = require(... .. ".launchers")
local timew     = require(... .. ".timew")

-- local systray = require(... .. ".systray")
-- local layout, layout_popup = require(... .. ".layout")()

return function(s)
  s.bar = awful.popup({
    screen = s,
    type = "dock",
    minimum_height = s.geometry.height,
    maximum_height = s.geometry.height,
    minimum_width = dpi(40),
    maximum_width = dpi(40),
    placement = awful.placement.left,
    widget = {
      {
        {
          { -- Top
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
          taglist(s), -- Middle
          { -- Bottom
            {
              timew,
              brightness,
              volume,
              notif,
              -- layout,
              battery,
              clock,
              --systray,
              spacing = dpi(8),
              layout = wibox.layout.fixed.vertical,
            },
            bottom = dpi(6),
            widget = wibox.container.margin,
          },
          layout = wibox.layout.align.vertical,
          expand = "none",
        },
        left    = dpi(3),
        right   = dpi(3),
        widget  = wibox.container.margin,
      },
      bg      = beautiful.wibar_bg,
      widget  = wibox.container.background,
    },
  })

  -- Reserve screen space
  s.bar:struts({
    left = s.bar.maximum_width,
  })

  -- local function remove_bar(c)
  --   if c.fullscreen or c.maximized then
  --     c.screen.bar.visible = false
  --   else
  --     c.screen.bar.visible = true
  --   end
  -- end

  -- -- i dont really understand this one
  -- local function add_bar(c)
  --   if c.fullscreen or c.maximized then
  --     c.screen.bar.visible = true
  --   end
  -- end

  --client.connect_signal("property::fullscreen", remove_bar)
  --client.connect_signal("request::unmanage", add_bar)
end
