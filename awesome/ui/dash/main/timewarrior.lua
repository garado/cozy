
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

-- Starts/stops Timewarrior time tracking.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")
local widgets = require("ui.widgets")
local user_vars = require("user_variables")
local string = string

local Elevated = require("ui.nav.navitem").Elevated
local Box = require("ui.nav.box")

local update_ui
local ui_timew_started, ui_timew_stopped

local function create_topic_buttons()

  local function create_topic_button(topic)
    return widgets.button.text.normal({
      text = topic,
      text_normal_bg = beautiful.fg,
      normal_bg = beautiful.surface0,
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
    markup = helpers.ui.colorize_text("Start a new session", beautiful.fg),
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

local function create_ui_text(header, text, text_size)
  local header = wibox.widget({
    {
      markup = helpers.ui.colorize_text(header, beautiful.subtitle),
      font = beautiful.font_name .. "Bold 10", 
      valign = "center",
      align = "center",
      widget = wibox.widget.textbox,
    },
    current_time_text,
    layout = wibox.layout.fixed.vertical,
  })

  local text = wibox.widget({
    markup = helpers.ui.colorize_text(text, beautiful.fg),
    font = beautiful.alt_font_name .. text_size,
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    header,
    text,
    layout = wibox.layout.fixed.vertical,
  })

end

--------

function ui_timew_started()
  local current_time = create_ui_text("CURRENT SESSION", "--", 30)
  --local total_this_tag = create_ui_text("TOTAL TAG", "--", 15)
  local total_all_tags = create_ui_text("TOTAL TODAY", "--", 15)
  local current_tag = create_ui_text("WORKING ON", "--", 15)

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

  -- update current tag
  local cmd = "timew | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tag = string.gsub(stdout, "Tracking ", "")
    local markup = helpers.ui.colorize_text(tag, beautiful.fg)
    current_tag.children[2]:set_markup_silently(markup)
  end)

  local stop_button = widgets.button.text.normal({
    text = "Stop",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
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
    {
      current_time,
      {
        current_tag,
        total_all_tags,
        --total_this_tag,
        spacing = dpi(20),
        layout = wibox.layout.fixed.horizontal,
      },
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    stop_button,
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

return helpers.ui.create_boxed_widget(timew_widget, dpi(0), dpi(340), beautiful.dash_widget_bg)

