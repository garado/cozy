
-- █▄▄ █░░ █░█ █▀▀ ▀█▀ █▀█ █▀█ ▀█▀ █░█ 
-- █▄█ █▄▄ █▄█ ██▄ ░█░ █▄█ █▄█ ░█░ █▀█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local strutil = require("utils.string")
local bt = require("backend.cozy.bluetooth")

-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

local status = wibox.widget({
  ui.textbox({
    text = "Bluetooth",
    font = beautiful.font_med_m,
  }),
  layout = wibox.layout.align.horizontal,
})

local devices = wibox.widget({
  ui.textbox({
    text = "Devices",
    color = beautiful.neutral[200],
  }),
  {
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(6),
  layout = wibox.layout.fixed.vertical,
})

local function gen_device(device)
  local indicator = wibox.widget({
    forced_width = dpi(6),
    forced_height = dpi(6),
    bg = beautiful.green[300],
    shape = gears.shape.circle,
    widget = wibox.container.background,
  })

  local name = ui.textbox({
    text = device[1]
  })

  local d = wibox.widget({
    indicator,
    name,
    spacing = dpi(8),
    layout = wibox.layout.fixed.horizontal,
  })

  return d
end

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local popup = awful.popup({
  type = "splash",
  minimum_height = dpi(300),
  maximum_height = dpi(300),
  minimum_width  = dpi(400),
  maximum_width  = dpi(400),
  bg = beautiful.neutral[800],
  ontop     = true,
  visible   = false,
  placement = awful.placement.centered,
  widget = wibox.widget({
    {
      {
        status,
        devices,
        spacing = dpi(6),
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(25),
      widget = wibox.container.margin,
    },
    widget = wibox.container.background,
  })
})

bt:get_devices()

bt:connect_signal("ready::devices", function(_, data)
  devices.children[2]:reset()
  for i = 1, #data do
    local d = gen_device(data[i])
    devices.children[2]:add(d)
  end
end)

bt:connect_signal("setstate::open", function()
  bt.screen = awful.screen.focused()
  popup.visible = true
end)

bt:connect_signal("setstate::close", function()
  popup.visible = false
end)
