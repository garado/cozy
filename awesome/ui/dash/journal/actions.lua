-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

-- Buttons for opening and reloading Ledger content.

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local journal = require("core.system.journal")
local dash = require("core.cozy.dash")
local area = require("modules.keynav.area")
local simplebtn = require("helpers.ui").simple_button
local navbtn    = require("modules.keynav.navitem").SimpleButton

local function create_button(text)
  local btn = simplebtn({
    text = text,
    font = beautiful.base_small_font,
    bg   = beautiful.cash_action_btn,
    margins = {
      left   = dpi(15),
      right  = dpi(15),
      top    = dpi(10),
      bottom = dpi(10),
    }
  })

  local nav_btn = navbtn({
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

return function()
  return actions, nav_actions
end

