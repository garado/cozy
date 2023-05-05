
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local awful = require("awful")
local dash  = require("backend.state.dash")
local cal   = require("backend.system.calendar")
local header = require("frontend.widget.dash.header")

-- The header contents will change depending on which tab is showing.
local calheader = header()

-- Set up header tab navigation
calheader:add_sb("Week", function()
  cal:emit_signal("tab::set", "weekview")
end)

calheader:add_sb("List", function()
  cal:emit_signal("tab::set", "listview")
end)

local weekview = require(... .. ".weekview")(calheader)

local container
local content = weekview

--------

container = wibox.widget({
  calheader,
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

cal:emit_signal("tab::set", "weekview")
return function()
  return container, false
end
