
-- █▀█ █▀█ █▀▀ █░█ █ █▀▀ █░█░█ 
-- █▀▀ █▀▄ ██▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local scale = 0.3

local preview = wibox.widget({
  {
    ui.button({ text = "Test button " }),
    layout = wibox.layout.fixed.vertical,
  },
  bg = beautiful.neutral[900],
  forced_width = dpi(1920 * scale),
  forced_height = dpi(1080 * scale),
  widget = wibox.container.background,
})

return function()
  return wibox.widget({
    ui.textbox({
      text  = "Theme preview",
      font  = beautiful.font_bold_s,
      align = "left",
    }),
    preview,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.vertical,
  })
end
