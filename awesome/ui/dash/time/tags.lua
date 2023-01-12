
-- ▀█▀ ▄▀█ █▀▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█ 

-- Selectable list of tags.

local wibox = require("wibox")
local time  = require("core.system.time")

local widget = wibox.widget({
  widget = wibox.widget.textbox
})

--- Generate wibox from tag
local function create_tag_entry(tag)
end

time:connect_signal("ready::tags", function()
  for tag in pairs(time.tags) do
    local tag_wibox, nav_tag = create_tag_entry(tag)
  end
end)

return function()
  return widget
end
