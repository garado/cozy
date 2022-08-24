
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")
local helpers = require("helpers")
local widgets = require("ui.widgets")
local user_vars = require("user_variables")
local string = string

local update_ui
local ui_timew_started, ui_timew_stopped

local function create_topic_buttons()

  local function create_topic_button(topic)
    return widgets.button.text.normal({
      text = topic,
      text_normal_bg = beautiful.xforeground,
      normal_bg = beautiful.nord1,
      animate_size = false,
      font = beautiful.font,
      size = 12,
      on_release = function()
        awful.spawn("timew start " .. topic)
        update_ui(ui_timew_started())
      end
    })
  end

  local topic_buttons = wibox.widget({
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })

  local topic_list = user_vars.pomo.topics
  for i = 1, #topic_list do
    local button = create_topic_button(topic_list[i])
    topic_buttons:add(button)
  end

  return topic_buttons
end

function ui_timew_stopped()
  local text = wibox.widget({
    markup = helpers.ui.colorize_text("Start a new session", beautiful.xforeground),
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    text,
    create_topic_buttons(),
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })
end

--------

function ui_timew_started()

  -- duration of current session
  local current_time_text = wibox.widget({
    markup = helpers.ui.colorize_text("--", beautiful.xforeground),
    font = beautiful.alt_font_name .. "Light 30",
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })

  local current_time = wibox.widget({
    {
      markup = helpers.ui.colorize_text("CURRENT SESSION", beautiful.nord3),
      font = beautiful.font_name .. "Bold 10", 
      valign = "center",
      align = "center",
      widget = wibox.widget.textbox,
    },
    current_time_text,
    layout = wibox.layout.fixed.vertical,
  })

  -- duration of all sessions today combined
  local total_time_text = wibox.widget({
    markup = helpers.ui.colorize_text("--", beautiful.xforeground),
    font = beautiful.alt_font_name .. "Light 30",
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })
  
  local total_time = wibox.widget({
    {
      markup = helpers.ui.colorize_text("TOTAL TODAY", beautiful.nord3),
      font = beautiful.font_name .. "Bold 10", 
      valign = "center",
      align = "center",
      widget = wibox.widget.textbox,
    },
    total_time_text,
    layout = wibox.layout.fixed.vertical,
  })

  -- turns 6:15:08 (H+:MM:SS) into 6h 15m
  local function format_time(str)
    str = string.gsub(str, "[^0-9:]", "")
    str = string.gsub(str, ":[0-9]+$", "")
    local hour = string.gsub(str, ":[0-9]+$", "")
    local min = string.gsub(str, "[0-9]+:", "")
    local txt = tonumber(min) .. "m"
    if tonumber(hour) > 0 then
      txt = hour .. "h " .. txt
    end
    return txt
  end
  
  -- update current time and total time every 60 seconds
  local minute_timer = gears.timer {
    timeout = 60,
    call_now = true,
    autostart = false,
    callback = function()
      local total_cmd = "timew sum | tail -n 2"
      awful.spawn.easy_async_with_shell(total_cmd, function(stdout)
        local markup = helpers.ui.colorize_text(format_time(stdout), beautiful.xforeground)
        total_time_text:set_markup_silently(markup)
      end)
      
      local curr_cmd = "timew | tail -n 1"
      awful.spawn.easy_async_with_shell(curr_cmd, function(stdout)
        local markup = helpers.ui.colorize_text(format_time(stdout), beautiful.xforeground)
        current_time_text:set_markup_silently(markup)
      end)
    end
  }
  minute_timer:start()

  local stop_button = widgets.button.text.normal({
    text = "Stop",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord1,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      awful.spawn.with_shell("timew stop")
      minute_timer:stop()
      update_ui(ui_timew_stopped())
    end
  })

  return wibox.widget({
    current_time,
    total_time,
    stop_button,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  })
end

-- assemble widget
local timew_widget = wibox.widget({
  {
    helpers.ui.create_dash_widget_header("Timewarrior"),
    {
      id = "content",
      ui_timew_stopped(),
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
    content:set(1, ui_timew_stopped())
  else
    content:set(1, ui_timew_started())
  end
end)

return helpers.ui.create_boxed_widget(timew_widget, dpi(0), dpi(350), beautiful.dash_widget_bg)

