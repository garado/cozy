
-- █▄▄ █▀█ █▀█ █▄▀ █▀▄▀█ ▄▀█ █▀█ █▄▀ █▀ 
-- █▄█ █▄█ █▄█ █░█ █░▀░█ █▀█ █▀▄ █░█ ▄█ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local bmcore   = require("core.cozy.bookmarks")
local keynav   = require("modules.keynav")
local colorize = require("helpers.ui").colorize_text

local sidebar, nav_sidebar = require(... .. ".sidebar")()
local list, nav_list = require(... .. ".list")()

local navigator, _ = keynav.navigator({
  name = "nav_bookmarks",
  root_children = {
    nav_sidebar,
    nav_list,
  },
  root_keys = {
    ["R"] = function()
      bmcore:read()
    end
  },
})

local header = wibox.widget({
  markup = colorize("Bookmarks", beautiful.fg),
  align  = "center",
  valign = "center",
  font   = beautiful.alt_large_font,
  widget = wibox.widget.textbox,
})

local bookmarks = awful.popup({
  type = "splash",
  minimum_height = dpi(600),
  maximum_height = dpi(600),
  minimum_width = dpi(980),
  maximum_width = dpi(980),
  bg = beautiful.dash_widget_bg,
  ontop = true,
  visible = false,
  placement = awful.placement.centered,
  widget = wibox.widget({
    { -- sidebar
      {
        {
          header,
          sidebar,
          spacing = dpi(15),
          forced_width = dpi(200),
          layout  = wibox.layout.fixed.vertical,
        },
        margins = dpi(20),
        widget  = wibox.container.margin,
      },
      bg     = beautiful.bg_l1,
      widget = wibox.container.background,
    },
    { -- list
      {
        list,
        margins = dpi(20),
        widget  = wibox.container.margin,
      },
      bg     = beautiful.dash_widget_bg,
      widget = wibox.container.background,
    },
    layout  = wibox.layout.fixed.horizontal,
  }),
})

bmcore:connect_signal("setstate::open", function()
  bookmarks.visible = true
  navigator:start()
end)

bmcore:connect_signal("setstate::close", function()
  bookmarks.visible = false
  navigator:stop()
end)

return function(_) return bookmarks end
