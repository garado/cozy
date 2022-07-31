
-- █▀█ █▀█ █▀▄▀█ █▀█ █▀▄ █▀█ █▀█ █▀█
-- █▀▀ █▄█ █░▀░█ █▄█ █▄▀ █▄█ █▀▄ █▄█

-- I have no idea wtf I'm doing

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")
local widgets = require("ui.widgets")

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄   █▀ ▀█▀ █░█ █▀▀ █▀▀
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀   ▄█ ░█░ █▄█ █▀░ █▀░

local pomodoro = { 
  current_state = "start",
  topic = nil,
  time = nil,
  states = {
    "start", "select_topic", "select_time", "tick", "complete" 
  },
  topics = {
    "School", "Coding", "Hobby", "Personal",
  },
  times = {
    "5m", "15m", "25m", "60m",
  },
}

function pomodoro:timer_tick(time)
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
      self:complete()
    end,
  }
end

-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄   █▀ ▀█▀ █░█ █▀▀ █▀▀
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀   ▄█ ░█░ █▄█ █▀░ █▀░

function button(text)
	return wibox.widget({
    widgets.button.text.state({
	  	forced_width = dpi(100),
	  	forced_height = dpi(40),
	  	normal_bg = beautiful.nord1,
	  	normal_shape = gears.shape.rounded_rect,
	  	on_normal_bg = beautiful.nord3,
	  	text_normal_bg = beautiful.nord10,
	  	text_on_normal_bg = beautiful.nord4,
      font = beautiful.header_font_name .. "Light",
	  	size = 10,
	  	text = text,
	  }),
    widget = wibox.container.place,
  })
end

-- STATE 0: Start
function pomodoro:state0_start()
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
  
  local function button_cmd()
    self.state = "select_topic"
  end

  local letsdoit = button("Let's do it!")
  letsdoit:buttons(gears.table.join(awful.button({}, 1, nil, function()
  	button_cmd()
  end)))
  
  local widget = wibox.widget({
    header,
    letsdoit,
    spacing = dpi(-160),
    layout = wibox.layout.flex.vertical,
  })

  return widget
end

-- STATE 1: Topic selection 
function pomodoro:state1_select_topic()
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text("topic select!", beautiful.xforeground),
      font = beautiful.header_font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  local widget = wibox.widget({
    header,
    layout = wibox.layout.fixed.vertical,
  })

  return widget
end

function pomodoro:state2_select_time()
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text("time select!", beautiful.xforeground),
      font = beautiful.header_font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  local widget = wibox.widget({
    header,
    layout = wibox.layout.fixed.vertical,
  })

  return widget
end
  
-- STATE 3: Timer
function pomodoro:state3_tick()
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

-- STATE 4: Complete
function pomodoro:state4_complete()
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text("complete!", beautiful.xforeground),
      font = beautiful.header_font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  local widget = wibox.widget({
    header,
    layout = wibox.layout.fixed.vertical,
  })

  return widget
end

function pomodoro:widget()
  local current_state = pomodoro.current_state
  local pomo = nil
  if current_state == "start" then
    pomo = self:state0_start()
  elseif current_state == "select_topic" then
    pomo = self:state1_select_topic()
  elseif current_state == "select_time" then
    pomo = self:state2_select_time()
  elseif current_state == "tick" then
    pomo = self:state3_tick()
  elseif current_state == "complete" then
    pomo = self:state4_complete()
  end
  return pomo 
end


return helpers.ui.create_boxed_widget(pomodoro:widget(), dpi(300), dpi(300), beautiful.dash_widget_bg)

