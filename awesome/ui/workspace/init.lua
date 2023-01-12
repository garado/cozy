
-- █░█░█ █▀█ █▀█ █▄▀ █▀ █▀█ ▄▀█ █▀▀ █▀▀    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ▀▄▀▄▀ █▄█ █▀▄ █░█ ▄█ █▀▀ █▀█ █▄▄ ██▄    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local vpad = require("helpers.ui").vertical_pad
local colorize = require("helpers.ui").colorize_text
local wspacecore = require("core.cozy.workspace")

local nav = require("modules.keynav")
local navigator = nav.navigator
local Area = nav.area
local Elevated = nav.navitem.Elevated

-- Keyboard navigation


-- █░█ █ 
-- █▄█ █ 

local wspace_list = wibox.widget({
  spacing = dpi(20),
  layout  = wibox.layout.fixed.horizontal,
})

local fuck = {
  "I", "II", "III", "IV", "V", "VI", "VII", "VIII"
}

for i = 1, 8 do
  local argh = wibox.widget({
    markup = colorize(fuck[i], beautiful.fg),
    font   = beautiful.base_small_font,
    widget = wibox.widget.textbox,
  })
  wspace_list:add(argh)
end

local header = wibox.widget({
  markup = colorize("Workspace Switcher", beautiful.main_accent),
  font   = beautiful.alt_large_font,
  widget = wibox.widget.textbox,
})

local prompt = wibox.widget({
  markup = colorize("Press 1-8 to jump to workspace", beautiful.fg),
  align  = "center",
  valign = "center",
  font   = beautiful.base_small_font,
  widget = wibox.widget.textbox,
})

local switcher_contents = wibox.widget ({
  {
    header,
    {
      wspace_list,
      widget = wibox.container.place,
    },
    prompt,
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.background,
  bg = beautiful.switcher_bg,
})

local switcher_width = dpi(550)
local switcher = awful.popup ({
  type = "popup_menu",
  minimum_width = switcher_width,
  maximum_width = switcher_width,
  placement = awful.placement.top,
  bg = beautiful.transparent,
  shape = gears.shape.rect,
  ontop = true,
  visible = false,
  widget = wibox.widget({
    {
      {
        switcher_contents,
        widget = wibox.container.place,
      },
      margins = dpi(10),
      widget = wibox.container.margin,
    },
    bg = beautiful.switcher_bg,
    widget = wibox.container.background,
  }),
})


wspacecore:connect_signal("state::open", function()
  switcher.visible = true
  -- navigator:start()
end)

wspacecore:connect_signal("state::close", function()
  switcher.visible = false
  -- navigator:stop()
end)

return function()
  return switcher
end
