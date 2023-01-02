
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

-- Integrated with jrnl
-- https://github.com/jrnl-org/jrnl

local wibox = require("wibox")
local area  = require("modules.keynav.area")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local journal = require("core.system.journal")

-- Imports
local lock_ui     = require(... .. ".lock")
local contents    = require(... .. ".contents")()
local entrylist, nav_entrylist = require(... .. ".entrylist")()

-- Keyboard navigation
local nav_journal = area:new({ name = "journal" })
nav_journal:append(nav_entrylist)

-- █░█ █ 
-- █▄█ █ 

local sidebar = wibox.widget({
  wibox.widget({
    markup = colorize("Journal", beautiful.fg),
    font   = beautiful.alt_large_font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  }),
  entrylist,
  spacing       = dpi(15),
  forced_width  = dpi(400),
  layout        = wibox.layout.fixed.vertical,
})

local unlock_ui = wibox.widget({
  sidebar,
  contents,
  spacing = dpi(15),
  layout  = wibox.layout.fixed.horizontal,
})

local ui = wibox.widget({
  lock_ui,
  layout = wibox.layout.fixed.vertical,
})

local widget = wibox.widget({
  {
    ui,
    margins = dpi(15),
    widget  = wibox.container.margin,
  },
  widget = wibox.container.place,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

journal:connect_signal("lock", function()
  journal.is_locked = true
  ui:set(1, lock_ui)
end)

journal:connect_signal("unlock", function()
  ui:set(1, unlock_ui)
end)

return function()
  return widget, nav_journal
end
