
-- █▀█ █▀█ █▀▄▀█ █▀█ █▀▄ █▀█ █▀█ █▀█
-- █▀▀ █▄█ █░▀░█ █▄█ █▄▀ █▄█ █▀▄ █▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄   █▀ ▀█▀ █░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀   ▄█ ░█░ █▄█ █▀░ █▀░

local pomodoro = { 
  current_state = "select_topic",
  states = {
    "select_topic", "select_time", "tick", "complete" 
  },
  topic = nil,
  time = nil,
}

function pomodoro.prompt()
end

function pomodoro.select_topic(topic_selected)
end

function pomodoro.select_time(time_selected)
end

function pomodoro.timer_tick(time)
  -- Ticks every 1 second
  -- Updates progress bar ui
  local second_timer = gears.timer {
    timeout = 1,
    call_now = false,
    autostart = false,
    callback = function()
    end,
  }
 
  -- Actual timer
  local pepedoro_timer = gears.timer {
    timeout = time,
    call_now = false,
    autostart = false,
    callback = function()
      second_timer:stop()
      self.complete()
    end,
  }
end

function pomodoro.start()
end

function pomodoro.stop()
end

function pomodoro.complete()
end


-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄   █▀ ▀█▀ █░█ █▀▀ █▀▀
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀   ▄█ ░█░ █▄█ █▀░ █▀░

-- STATE 1: Topic selection 
local function state1()
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text("Get to work!", beautiful.xforeground),
      font = beautiful.header_font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  local prompt = wibox.widget({
    widget = wibox.widget.textbox,
  })
  
  local widget = wibox.widget({
    header,
    prompt,
    layout = wibox.layout.flex.vertical,
  })

  return widget
end

local function state2()
  local widget = wibox.widget({
    --header,
    layout = wibox.layout.fixed.vertical,
  })

  return state2
end
  
-- STATE 3: Timer
local function state3()
  local timer = wibox.widget({
    {
      {
        widget = wibox.widget.textbox,
        markup = helpers.ui.colorize_text("23:59", beautiful.xforeground),
        font = beautiful.font .. "25",
        align = "center",
        valign = "center",
      },
      value = 0.5,
      max_value = 1,
      min_value = 0,
      color = beautiful.nord6, -- fg
      border_color = beautiful.nord10, -- bg
      forced_height = dpi(200),
      forced_width = dpi(200),
      widget = wibox.container.radialprogressbar,
    },
    widget = wibox.container.place,
  })
  
  local widget = wibox.widget({
      timer,
      layout = wibox.layout.fixed.vertical,
  })

  return widget
end

local function state4()
  local widget = wibox.widget({
      --timer,
      layout = wibox.layout.fixed.vertical,
  })

  return widget
end

local function widget()
  local current_state = pomodoro.current_state
  local pomo = nil
  if current_state == "select_topic" then
    pomo = state1()
  elseif current_state == "select_time" then
    pomo = state2()
  elseif current_state == "tick" then
    pomo = state3()
  elseif current_state == "finished" then
    pomo = state4()
  end
  return pomo 
end

return helpers.ui.create_boxed_widget(widget(), dpi(300), dpi(300), beautiful.dash_widget_bg)
