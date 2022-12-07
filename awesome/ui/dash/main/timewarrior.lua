
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

-- Starts/stops Timewarrior time tracking.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colorize = require("helpers").ui.colorize_text
local box = require("helpers").ui.create_boxed_widget
local dash_header = require("helpers").ui.create_dash_widget_header
local widgets = require("ui.widgets")
local config = require("config")
local string = string

local Elevated = require("modules.keynav.navitem").Elevated
local Dashwidget = require("modules.keynav.navitem").Dashwidget
local Area = require("modules.keynav.area")

local nav_timewarrior   = Area:new({ name = "timewarrior" })
local nav_timew_topics  = Area:new({ name = "timew_topics", circular = true })
local nav_timew_actions = Area:new({ name = "timew_actions" })

local update_ui, init_start_ui
local ui_started, ui_stopped
local topic_list = config.pomo.topics

-- Creates a subsection.
-- Subsections: current session, working on, total today
local function create_ui_subsection(header, text, text_size)
  local _header = wibox.widget({
    markup = colorize(header, beautiful.timew_header_fg),
    font = beautiful.font_name .. "Bold 10",
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })

  local _text = wibox.widget({
    markup = colorize(text, beautiful.fg),
    font = beautiful.alt_font_name .. text_size,
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    _header,
    _text,
    layout = wibox.layout.fixed.vertical,
  })
end

-- █▀ ▀█▀ █▀█ █▀█ █▀█ █▀▀ █▀▄ 
-- ▄█ ░█░ █▄█ █▀▀ █▀▀ ██▄ █▄▀ 
-- When Timewarrior is stopped, display a list of topics.

-- Creates a button to start timew tracking for a given
-- topic (aka tag).
local function create_topic_button(topic)
  local topic_btn = widgets.button.text.normal({
    text = topic,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.timew_btn_bg,
    animate_size = true,
    font = beautiful.font,
    size = 12,
    on_release = function()
      awful.spawn("timew start " .. topic)
      nav_timewarrior:remove_all_items()
      nav_timewarrior:append(nav_timew_actions)
      init_start_ui()
      update_ui(ui_started)
    end
  })
  nav_timew_topics:append(Elevated:new(topic_btn))
  return topic_btn
end

-- Loops through all topics set in config and creates a button
-- for each.
local function create_topic_buttons()
  local topic_buttons = wibox.widget({
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })

  for i = 1, #topic_list do
    local button = create_topic_button(topic_list[i])
    topic_buttons:add(button)
  end

  return topic_buttons
end
local topic_buttons = create_topic_buttons()
local text = wibox.widget({
  markup = colorize("Start a new session", beautiful.fg),
  valign = "center",
  align = "center",
  widget = wibox.widget.textbox,
})

ui_stopped = wibox.widget({
  text,
  topic_buttons,
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

-- █▀ ▀█▀ ▄▀█ █▀█ ▀█▀ █▀▀ █▀▄ 
-- ▄█ ░█░ █▀█ █▀▄ ░█░ ██▄ █▄▀ 
-- When Timewarrior is started, show the current session time,
-- the current tag, and the total time worked today.
local current_time = create_ui_subsection("CURRENT SESSION", "--", 30)
local total_all_tags = create_ui_subsection("TOTAL TODAY", "--", 15)
local current_tag = create_ui_subsection("WORKING ON", "--", 15)

-- Timewarrior reports time in H+:MM:SS format (6:15:08)
-- But I prefer it in 6h 15m format.
local function format_time(str)
  -- remove whitespace and seconds
  str = string.gsub(str, "[%a+%s+\n\r]", "")
  str = string.gsub(str, ":%d+$", "")

  local min_str  = string.gsub(str, "^%d+:", "")
  local hour_str = string.gsub(str, ":%d+$", "")
  local min  = tonumber(min_str) or 0
  local hour = tonumber(hour_str)

  local txt = "--"
  local valid_hour = hour and hour > 0
  if min_str  then txt = min .. "m" end
  if valid_hour then txt = hour .. "h " .. txt end

  return txt
end

local stop_button = widgets.button.text.normal({
  text = "Stop",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.timew_btn_bg,
  animate_size = false,
  font = beautiful.font,
  size = 12,
  on_release = function()
    awful.spawn.with_shell("timew stop")
    awful.spawn.with_shell("echo 'all' | task status:pending stop")
    nav_timewarrior:remove_all_items()
    nav_timewarrior:append(nav_timew_topics)
    update_ui(ui_stopped)
  end
})
nav_timew_actions:append(Elevated:new(stop_button))

ui_started = wibox.widget({
  {
    current_time,
    {
      current_tag,
      total_all_tags,
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  stop_button,
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

-- The function to run whenever 
local function update_timew_information()
  -- current tag
  -- with the way I use taskwarrior, I always have multiple tasks,
  -- but I only need to use the 1st tag. so only take the 1st word
  local cmd = "timew | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tag = string.gsub(stdout, "Tracking ", "")
    tag = string.gsub(tag, "%s+.+$", "")
    local markup = colorize(tag, beautiful.fg)
    current_tag.children[2]:set_markup_silently(markup)
  end)

  -- total tracked time today across all tags
  local total_cmd = "timew sum | tail -n 2"
  awful.spawn.easy_async_with_shell(total_cmd, function(stdout)
    local markup = colorize(format_time(stdout), beautiful.fg)
    total_all_tags.children[2]:set_markup_silently(markup)
  end)

  -- current session time
  local curr_cmd = "timew | tail -n 1"
  awful.spawn.easy_async_with_shell(curr_cmd, function(stdout)
    local markup = colorize(format_time(stdout), beautiful.fg)
    current_time.children[2]:set_markup_silently(markup)
  end)
end

-- What to do when switching to timew start mode
function init_start_ui()
  update_timew_information()
end

-- Assemble widget
local timew_widget = wibox.widget({
  {
    dash_header("Timewarrior"),
    {
      id = "content",
      ui_stopped,
      layout = wibox.layout.fixed.vertical,
    },
    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

function update_ui(widget)
  local content = timew_widget:get_children_by_id("content")[1]
  content:set(1, widget)
end

-- check timew output and set widget state accordingly
local function read_timew_state()
  local cmd = "timew | tail -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local content = timew_widget:get_children_by_id("content")[1]
    if stdout:find("no active time tracking") then
      content:set(1, ui_stopped)
      nav_timewarrior:remove_all_items()
      nav_timewarrior:append(nav_timew_topics)
      nav_timewarrior.index = 1
    else
      content:set(1, ui_started)
      init_start_ui()
      nav_timewarrior:remove_all_items()
      nav_timewarrior:append(nav_timew_actions)
    end
  end)
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 
-- Emitted by Timewarrior hook
awesome.connect_signal("dash::update_timew", function()
  print("Test")
  read_timew_state()
end)

-- Only update widget whenever dashboard is opened
awesome.connect_signal("dash::opened", function()
  read_timew_state()
  --update_timew_information()
end)

-- set initial state
read_timew_state()

local container = box(timew_widget, dpi(0), dpi(340), beautiful.dash_widget_bg)

nav_timewarrior.widget = Dashwidget:new(container)

return function()
  return nav_timewarrior, container
end

