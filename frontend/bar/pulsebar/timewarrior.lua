
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- Display information on current Timewarrior session.

local ui = require("utils.ui")
local timew = require("backend.system.time")
local beautiful = require("beautiful")

local ICON = ""

local widget = ui.textbox({
  text = ICON .. "  No active time tracking",
  font = beautiful.font_reg_xs,
  visible = false,
})

timew:connect_signal("tracking::inactive", function()
  -- widget:update_text(ICON .. "  No active time tracking.")
  widget.visible = false
end)

timew:connect_signal("tracking::active", function()
  widget:update_text(ICON .. "  " ..timew.tracking.title)
  widget.visible = true
end)

return widget
