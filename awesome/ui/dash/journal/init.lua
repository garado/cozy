
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local colorize = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local journal = require("core.system.journal")

local lock      = require(... .. ".lock")
-- local details   = require(... .. ".details")
-- local entrylist = require(... .. ".entrylist")

local sidebar = wibox.widget({
  wibox.widget({
    markup = colorize("Journal", beautiful.fg),
    font   = beautiful.alt_large_font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  }),
  spacing = dpi(15),
  forced_height = dpi(730),
  layout = wibox.layout.fixed.vertical,
})

local rightside = wibox.widget({

})

local widget = wibox.widget({
  lock,
  margins = dpi(15),
  widget = wibox.container.margin,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

journal:connect_signal("journal::lock", function()
end)

journal:connect_signal("journal::unlock", function()
end)

return widget
