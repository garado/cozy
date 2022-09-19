
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

-- Starts/stops Timewarrior time tracking.

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local user_vars = require("user_variables")
local string = string

local Elevated = require("modules.keynav.navitem").Elevated
local Dashwidget = require("modules.keynav.navitem").Dashwidget
local Area = require("modules.keynav.area")

local nav_timewarrior   = Area:new({ name = "timewarrior" })
local nav_timew_topics  = Area:new({ name = "timew_topics", circular = true })
local nav_timew_actions = Area:new({ name = "timew_actions" })

local update_ui, init_start_ui
local ui_started, ui_stopped
local minute_timer
local topic_list = user_vars.pomo.topics

-- Creates a subsection.
-- Subsections: current session, working on, total today
local function create_ui_subsection(header, text, text_size)
  local _header = wibox.widget({
    markup = helpers.ui.colorize_text(header, beautiful.timew_header_fg),
    font = beautiful.font_name .. "Bold 10",
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })

  local _text = wibox.widget({
    markup = helpers.ui.colorize_text(text, beautiful.fg),
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
      nav_timewarrior:append(nav_timew_actions)
      nav_timewarrior:remove_item(nav_timew_topics)
      init_start_ui()
      update_ui(ui_started)
    end
  })
  nav_timew_topics:append(Elevated:new(topic_btn))
  return topic_btn
end

-- Loops through all topics set in user_vars and creates a button
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
  markup = helpers.ui.colorize_text("Start a new session", beautiful.fg),
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
  print("FORMAT TIME: input was "..str)
  str = string.gsub(str, "[^0-9:]", "")
  str = string.gsub(str, ":[0-9]+$", "")
  local hour_str = string.gsub(str, ":[0-9]+$", "")
  local min_str = string.gsub(str, "[0-9]+:", "")
  local hour = tonumber(hour_str)
  local min = tonumber(min_str)
  local txt = "--"
  if min  then txt = min .. "m" end
  if hour and not hour == 0 then txt = hour .. "h " .. txt end
  print("FORMAT TIME: output is "..txt)
  return txt
end

-- Init timer to be used.

local stop_button = widgets.button.text.normal({
  text = "Stop",
  text_normal_bg = beautiful.fg,
  normal_bg = beautiful.timew_btn_bg,
  animate_size = false,
  font = beautiful.font,
  size = 12,
  on_release = function()
    awful.spawn.with_shell("timew stop")
    minute_timer:stop()
    nav_timewarrior:append(nav_timew_topics)
    nav_timewarrior:remove_item(nav_timew_actions)
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
  layout = wibox.layout.fixed.vertical,
})

-- What to do when switching to timew start mode
function init_start_ui()
  -- Update current tag
  local cmd = "timew | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tag = string.gsub(stdout, "Tracking ", "")
    local markup = helpers.ui.colorize_text(tag, beautiful.fg)
    current_tag.children[2]:set_markup_silently(markup)
  end)
  minute_timer = gears.timer {
    timeout = 60,
    call_now = true,
    autostart = false,
    callback = function()
      -- total tracked time today across all tags
      local total_cmd = "timew sum | tail -n 2"
      awful.spawn.easy_async_with_shell(total_cmd, function(stdout)
        local markup = helpers.ui.colorize_text(format_time(stdout), beautiful.fg)
        total_all_tags.children[2]:set_markup_silently(markup)
      end)

      -- current session time
      local curr_cmd = "timew | tail -n 1"
      awful.spawn.easy_async_with_shell(curr_cmd, function(stdout)
        local markup = helpers.ui.colorize_text(format_time(stdout), beautiful.fg)
        current_time.children[2]:set_markup_silently(markup)
      end)
    end
  }
  minute_timer:start()
end

-- Assemble widget
local timew_widget = wibox.widget({
  {
    helpers.ui.create_dash_widget_header("Timewarrior"),
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

-- set initial state
local cmd = "timew | tail -n 1"
awful.spawn.easy_async_with_shell(cmd, function(stdout)
  local content = timew_widget:get_children_by_id("content")[1]
  if stdout:find("no active time tracking") then
    content:set(1, ui_stopped)
    nav_timewarrior:append(nav_timew_topics)
    nav_timewarrior.index = 1
  else
    content:set(1, ui_started)
    init_start_ui()
    nav_timewarrior:append(nav_timew_actions)
  end
end)

local container = helpers.ui.create_boxed_widget(timew_widget, dpi(0), dpi(340), beautiful.dash_widget_bg)

nav_timewarrior.widget = Dashwidget:new(container)

return function()
  return nav_timewarrior, container
end

