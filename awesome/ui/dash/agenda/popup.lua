
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█    █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄    █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- Popup used to add events

local wibox = require("wibox")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local navbase = require("modules.keynav.navitem").Base
local navbg = require("modules.keynav.navitem").Background
local gears = require("gears")

local calpopup_core = require("core.cozy.calpopup")

local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")

local calpopup
local cal, nav_cal = require('ui.dash.agenda.popup_calendar')()

--------------

local function create_details()
  local function create_prompt(prompt_text, font)
    return wibox.widget({
      markup = colorize(prompt_text, beautiful.fg_sub),
      align  = "start",
      valign = "start",
      font   = font,
      widget = wibox.widget.textbox,
    })
  end

  local title_prompt = create_prompt("Add title", beautiful.base_med_font)
  local place_prompt = create_prompt("Add location", beautiful.base_med_font)
  local when_prompt  = create_prompt("10:00", beautiful.base_med_font)

  return wibox.widget({
    title_prompt,
    place_prompt,
    when_prompt,
    layout = wibox.layout.fixed.vertical,
  })
end

local function calpopup_contents()
  return wibox.widget({
    {
      {
        cal,
        create_details(),
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(10),
      widget = wibox.container.margin,
    },
    bg = beautiful.red,
    widget = wibox.container.background,
  })
end

calpopup = awful.popup({
  type = "splash",
  minimum_height = dpi(600),
  maximum_height = dpi(600),
  minimum_width = dpi(700),
  maximum_width = dpi(700),
  bg = beautiful.transparent,
  ontop   = true,
  visible = false,
  placement = awful.placement.centered,
  widget = calpopup_contents()
})

-----------

local nav_calpopup = area:new({ name = "calpopup" })

calpopup_core:connect_signal("open", function()
  calpopup.visible = true
end)

calpopup_core:connect_signal("close", function()
  calpopup.visible = false
end)

return function(s) end
