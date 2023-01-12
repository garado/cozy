-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

-- Buttons for opening and reloading Ledger content.

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local box = require("helpers.ui").create_boxed_widget
local journal = require("core.system.journal")
local dash = require("core.cozy.dash")
local gears = require("gears")
local colorize = require("helpers.ui").colorize_text
local area = require("modules.keynav.area")
local navbg = require("modules.keynav.navitem").Background

local function create_button(text)
  local btn = wibox.widget({
    {
      markup = colorize(text, beautiful.fg),
      font   = beautiful.base_small_font,
      align  = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    forced_height = dpi(50),
    shape  = gears.shape.rounded_rect,
    bg     = beautiful.cash_action_btn,
    widget = wibox.container.background,
  })

  local nav_btn = navbg({
    widget = btn,
    bg_off = beautiful.cash_action_btn,
  })

  return btn, nav_btn
end

local open_btn, nav_open = create_button("Open ledger")
function nav_open:release()
  dash:close()
  journal:new_entry()
end

local reload_btn, nav_reload = create_button("Reload")
function nav_reload:release()
  journal:reload()
end

local nav_actions = area:new({
  name = "nav_actions",
  circular = true,
  children = {
    nav_open,
    nav_reload,
  }
})

local actions = wibox.widget({
  {
    open_btn,
    reload_btn,
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

local container = box(actions, dpi(0), dpi(80), beautiful.dash_widget_bg)
nav_actions.widget = navbg({ widget = container })

return function()
  return container, nav_actions
end

