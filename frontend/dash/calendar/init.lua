
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- Basically a Google Calendar clone.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local header = require("frontend.widget.dash.header")
local keynav = require("modules.keynav")

-- Import pages
local week_actions, week_content, nav_week = require(... .. ".week")()

local nav_calendar = keynav.area({
  name = "nav_calendar",
  items = {
    nav_week,
  },
})

local cal_header = header({
  title_text = "",
})

local content = week_content

return function()
  return ui.contentbox(header, content), nav_calendar
end
