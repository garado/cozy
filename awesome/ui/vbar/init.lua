
-- █░█ █▄▄ ▄▀█ █▀█ 
-- ▀▄▀ █▄█ █▀█ █▀▄ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local clock      = require(... .. ".clock")
local battery    = require(... .. ".battery")
-- local volume     = require(... .. ".volume")
-- local brightness = require(... .. ".brightness")
local taglist = require(... .. ".taglist")
-- local git     = require(... .. ".git_backup")
local notif   = require(... .. ".notif")
-- local app_launcher = require(... .. ".app_launcher")
-- local launchers = require(... .. ".launchers")
local timew     = require(... .. ".timew")
local logo    = require(... .. ".logo")
local layout = require(... .. ".layout")

-- local systray = require(... .. ".systray")

local top_vbar = wibox.widget({
  logo,
  layout = wibox.layout.fixed.vertical,
})

local bottom_vbar = wibox.widget({
  timew,
  layout,
  notif,
  battery,
  clock,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

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
            top_vbar,
            top = dpi(8),
            widget = wibox.container.margin,
          },
          taglist(s), -- Middle
          { -- Bottom
            bottom_vbar,
            bottom = dpi(6),
            widget = wibox.container.margin,
          },
          layout = wibox.layout.align.vertical,
          expand = "none",
        },
        margins = dpi(3),
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
