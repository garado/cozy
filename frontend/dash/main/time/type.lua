
-- ▀█▀ █▄█ █▀█ █▀▀    █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀    █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ 
-- ░█░ ░█░ █▀▀ ██▄    ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░    ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ 

local beautiful = require("beautiful")
local cozyconf  = require("cozyconf")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local sbtn  = require("frontend.widget.stateful-button")
local dash  = require("backend.cozy.dash")
local ss    = require("frontend.widget.single-select")
local keynav = require("modules.keynav")

local navitems = {}

local free_btn = sbtn({
  text = "Freerunning",
  deselect = {
    bg    = beautiful.neutral[700],
    bg_mo = beautiful.neutral[600],
  },
  func = function()
    dash:emit_signal("main::time::changestate", "active")
  end,
})
table.insert(navitems, free_btn)

local pomo_btn = sbtn({
  text = "Pomodoro",
  deselect = {
    bg    = beautiful.neutral[700],
    bg_mo = beautiful.neutral[600],
  },
  func = function()
    dash:emit_signal("main::time::changestate", "active")
  end,
})
table.insert(navitems, pomo_btn)

local select = wibox.widget({
  ui.textbox({
    text  = "Select session",
    align = "center",
    color = beautiful.neutral[300],
  }),
  {
    free_btn,
    pomo_btn,
    spacing = dpi(15),
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})

local cancel = btn({
  align = "center",
  text  = " Back",
  fg    = beautiful.neutral[300],
  func  = function()
    dash:emit_signal("main::time::changestate", "select")
  end
})

local widget = wibox.widget({
  select,
  {
    cancel,
    widget = wibox.container.place,
  },
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

widget.navitems = navitems
widget.keys = {
  ["BackSpace"] = function() dash:emit_signal("main::time::changestate", "select") end,
}

return widget
