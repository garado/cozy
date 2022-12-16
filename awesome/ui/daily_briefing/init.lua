
-- █▀▄ ▄▀█ █ █░░ █▄█    █▄▄ █▀█ █ █▀▀ █▀▀ █ █▄░█ █▀▀ 
-- █▄▀ █▀█ █ █▄▄ ░█░    █▄█ █▀▄ █ ██▄ █▀░ █ █░▀█ █▄█ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local colorize = require("helpers.ui").colorize_text
local vpad = require("helpers.ui").vertical_pad

-- █░█ █    ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▄█ █    █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- Greeting ------------------------
local greeting = wibox.widget({
  {
    {
      markup = colorize("Good morning,", beautiful.fg),
      align = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    {
      markup = colorize("Alexis", beautiful.fg),
      font = beautiful.font_name .. "Bold 20",
      align = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  bottom = dpi(20),
  widget = wibox.container.margin,
})

-- Debrief ------------------------
local debrief_text_tasks = colorize("3 tasks due", beautiful.main_accent)
local debrief_text_events = colorize("3 events", beautiful.main_accent)
local debrief_text = colorize("You have ", beautiful.fg) .. debrief_text_events ..
  colorize(" and ", beautiful.fg) .. debrief_text_tasks .. colorize(" today.", beautiful.fg)
local debrief = wibox.widget({
  {
    {
      markup = debrief_text,
      font = beautiful.alt_font_name .. "12",
      align = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  bottom = dpi(15),
  widget = wibox.container.margin,
})

-- Weather ------------------------
local weather = wibox.widget({
  {
    {
      markup = colorize("It's going to be cloudy today with a high of 68*.", beautiful.fg),
      font = beautiful.alt_font_name .. "12",
      align = "left",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  bottom = dpi(20),
  widget = wibox.container.margin,
})

-- Events ------------------------
local _events_overview_header = wibox.widget({
  {
    markup = colorize("EVENTS", beautiful.fg),
    font = beautiful.font_name .. "Bold 12",
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local events_overview = wibox.widget({
  _events_overview_header,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

-- Tasks ----------------------------
local _tasks_overview_header = wibox.widget({
  {
    markup = colorize("TASKS", beautiful.fg),
    font = beautiful.font_name .. "Bold 12",
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox,
  },
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

local tasks_overview = wibox.widget({
  _tasks_overview_header,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

-- Assemble contents ---------------------------
local _daily_briefing = wibox.widget({
  greeting,
  debrief,
  weather,
  events_overview,
  tasks_overview,
  layout = wibox.layout.fixed.vertical,
})

-- Assemble the popup ------------------------
local daily_briefing_width = dpi(500)
local daily_briefing = awful.popup ({
  type = "popup_menu",
  minimum_width = daily_briefing_width,
  maximum_width = daily_briefing_width,
  placement = awful.placement.centered,
  bg = beautiful.transparent,
  shape = gears.shape.rect,
  ontop = true,
  widget = {
      {
        _daily_briefing,
        margins = dpi(30),
        widget = wibox.container.margin,
      },
    widget = wibox.container.background,
    bg = beautiful.ctrl_bg,
  },
  visible = false,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
awesome.connect_signal("daily_briefing::toggle", function()
  daily_briefing.visible = not daily_briefing.visible
end)

awesome.connect_signal("daily_briefing::open", function()
  daily_briefing.visible = true
end)

awesome.connect_signal("daily_briefing::close", function()
  daily_briefing.visible = false
end)

return function()
  return daily_briefing
end
