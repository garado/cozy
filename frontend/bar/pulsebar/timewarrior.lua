
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- Display information on current Timewarrior session.

local ui = require("utils.ui")
local timew = require("backend.system.time")
local beautiful = require("beautiful")
local conf = require("cozyconf")
local theme = require("theme.colorschemes."..conf.theme_name.."."..conf.theme_style)

local ICON = ""

local widget = ui.textbox({
  text = ICON .. "  No active time tracking",
  font = beautiful.font_reg_xs,
  color = theme.pulsebar_fg_l == "dark" and beautiful.neutral[900] or beautiful.neutral[100],
  visible = false,
})

timew:connect_signal("tracking::inactive", function()
  widget:update_text(ICON .. "  No active time tracking.")
  widget.visible = false
end)

timew:connect_signal("tracking::active", function()
  widget:update_text(ICON .. " " .. timew.tracking.tags[1] .. ": " .. timew.tracking.annotation)
  widget.visible = true
end)

return widget
