
-- █▀█ █▀▀ █▀█ █▀▀ █▀▄ █▀█ █▀█ █▀█
-- █▀▀ ██▄ █▀▀ ██▄ █▄▀ █▄█ █▀▄ █▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local utils = require("utils")

local _awmodoro = { 
  current_state = "select_topic",
  states = {
    "select_topic", "select_time", "tick", "complete" 
  }
}

function _awmodoro.select_topic(topic_selected)
end

function _awmodoro.select_time(time_selected)
end

function _awmodoro.timer_tick(time)
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

function _awmodoro.start()
end

function _awmodoro.stop()
end

function _awmodoro.complete()
end

-----

local function widget()
  -----------------
  -- UI ELEMENTS --
  -----------------
  -- STATE 1: Topic selection 
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = "Get to work!",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  -- STATE 2: Time selection



  -- STATE 3: Timer
  local timer = wibox.widget({
    {
      {
        {
          widget = wibox.widget.textbox,
          text = "23:59",
          font = beautiful.font_name .. "Medium 25",
          align = "center",
          valign = "center",
        },
        { -- replace with button
          text = 'pause',
          widget = wibox.widget.textbox,
          align = "center",
          valign = "center",
        }, 
        spacing = dpi(-120),
        layout = wibox.layout.flex.vertical,
      },
      value = 0.5,
      max_value = 1,
      min_value = 0,
      color = beautiful.nord6, -- fg
      border_color = beautiful.nord10, -- bg
      forced_height = dpi(300),
      widget = wibox.container.radialprogressbar,
    },
    margins = dpi(30),
    widget = wibox.container.margin,
  })
 
  -- STATE 4: Finish





  --------------
  -- ASSEMBLE --
  --------------
  local state1 = wibox.widget({
    header,
    layout = wibox.layout.fixed.vertical,
  })

  local state2 = wibox.widget({
    header,
    layout = wibox.layout.fixed.vertical,
  })

  local state3 = wibox.widget({
      timer,
      layout = wibox.layout.fixed.vertical,
  })

  local state4 = wibox.widget({
      timer,
      layout = wibox.layout.fixed.vertical,
  })
  
  local pepedoro = state1
  --local pepedoro = state
  --if current_state == "select_topic" then
  --  pepedoro = state1
  --elseif current_state == "select_time" then
  --  pepedoro = state2
  --elseif current_state == "tick" then
  --  pepedoro = state3
  --elseif current_state == "finished" then
  --  pepedoro = state4
  --end

  return pepedoro 
end

return utils.ui.create_boxed_widget(widget(), dpi(300), dpi(300), beautiful.background_med)
