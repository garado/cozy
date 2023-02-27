
-- ▄▀█ █▀█ █▀█    █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ 
-- █▀█ █▀▀ █▀▀    █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ 

-- An app launcher for touchscreen devices.
-- For non-touchscreen devices, Cozy uses Rofi (default alt + r)

local awful = require("awful")
local gears = require("gears")
local ui    = require("helpers.ui")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local lcore = require("core.cozy.launcher")

local LAUNCHER_HEIGHT = dpi(600)
local LAUNCHER_WIDTH  = dpi(400)
local APP_LIST = { "xournalpp", "onboard", "nautilus" }

----------------

local app_grid = wibox.widget({
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

local function create_app_icon(appname)
  local buttons = gears.table.join(
    awful.button({}, 1, function()
      print('launching ' .. appname)
      awful.spawn(appname)
      lcore:emit_signal("setstate::close")
    end)
  )

  local app_wibox = wibox.widget({
    {
      {
        {
          markup = ui.colorize(appname, beautiful.fg_0),
          align  = "center",
          valign = "center",
          font   = beautiful.font_reg_s,
          widget = wibox.widget.textbox,
        },
        widget = wibox.container.place,
      },
      margins = dpi(15),
      widget  = wibox.container.margin,
    },
    bg     = beautiful.bg_3,
    widget = wibox.container.background,
    ----
    buttons = buttons,
  })

  return app_wibox
end

for i = 1, #APP_LIST do
  local app_icon = create_app_icon(APP_LIST[i])
  app_grid:add(app_icon)
end

----------------

local closebtn = wibox.widget({
  {
    {
      {
        markup = ui.colorize("", beautiful.fg_0),
        font   = beautiful.font_reg_s,
        align  = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      widget = wibox.container.place,
    },
    margins = dpi(15),
    widget  = wibox.container.margin,
  },
  bg     = beautiful.bg,
  widget = wibox.container.background,
  -----
  buttons = gears.table.join(
    awful.button({}, 1, function()
      lcore:emit_signal("setstate::close")
    end))
})

----------------

local launcher_contents = wibox.widget({
  {
    {
      {
        closebtn,
        app_grid,
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.place,
    },
    margins = dpi(15),
    widget  = wibox.container.margin,
  },
  bg     = beautiful.bg,
  widget = wibox.container.background,
})


local launcher = awful.popup ({
  type = "popup_menu",
  minimum_width = LAUNCHER_WIDTH,
  maximum_width = LAUNCHER_WIDTH,
  minimum_height = LAUNCHER_HEIGHT,
  maximum_height = LAUNCHER_HEIGHT,
  placement = awful.placement.centered,
  shape   = gears.shape.rounded_rect,
  ontop   = true,
  visible = false,
  widget  = launcher_contents,
})

lcore:connect_signal("setstate::open", function()
  launcher.visible = true
end)

lcore:connect_signal("setstate::close", function()
  launcher.visible = false
end)

return function()
  awesome.connect_signal("launcher::open", function()
    lcore:emit_signal("setstate::open")
  end)
end
