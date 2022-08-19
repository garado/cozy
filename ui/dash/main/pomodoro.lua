
-- █▀█ █▀█ █▀▄▀█ █▀█ █▀▄ █▀█ █▀█ █▀█
-- █▀▀ █▄█ █░▀░█ █▄█ █▄▀ █▄█ █▀▄ █▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")
local helpers = require("helpers")
local widgets = require("ui.widgets")
local naughty = require("naughty")
local math = math

local widget = wibox.container.margin()
local redraw_widget

local pomodoro = {
  current_state = "start",
  selected_topic = nil,
  selected_time = nil,
  time_remaining = nil,
  preserved = false,
  timer_state = "stopped",
  states = {
    "start", "select_topic", "select_time", "tick", "complete" 
  },
  timer_states = {
    "stopped", "ticking", "paused",
  },
  topics = {
    "School", "Coding", "Hobby", "Personal",
  },
  times = {
    "1m", "15m", "25m", "60m",
  },
}

local function reset_pomodoro()
  pomodoro.current_state = "start"
  pomodoro.selected_topic = nil
  pomodoro.selected_time = nil
  pomodoro.time_remaining = nil
  pomodoro.preserved = false
  awful.spawn.easy_async("xrdb -remove")
  timer_state = "stopped"
end

-- █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- ▄█ ░█░ █▀█ █▀▄ ░█░
local function ui_start()
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

  local letsdoit = widgets.button.text.normal({
    text = "Let's do it!",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord3,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "select_topic"
      redraw_widget()
    end
  })
 
  -- Assemble the widget!
  local widget = wibox.widget({
    {
      header,
      letsdoit,
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
      widget = wibox.container.margin,
    },
    widget = wibox.container.place,
  })
    
  local box_container = wibox.container.background()
  box_container.bg = beautiful.dash_widget_bg 
  box_container.forced_height = dpi(350)
  box_container.forced_width = dpi(300)
  box_container.shape = gears.shape.rounded_rect
  local widget_cont = wibox.widget({
    {
      {
        widget,
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      widget = box_container,
    },
    margins = dpi(10),
    color = "#FF000000",
    widget = wibox.container.margin,
  })
  return widget_cont
end


-- █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀   ▀█▀ █▀█ █▀█ █ █▀▀
-- ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░   ░█░ █▄█ █▀▀ █ █▄▄
local function create_topic_buttons()
  local buttons = wibox.widget({
    {
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(20),
    widget = wibox.container.margin,
  })

  local back_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "start"
      redraw_widget()
    end
  })

  for i,v in ipairs(pomodoro.topics) do
    local button = widgets.button.text.normal({
      text = v,
      text_normal_bg = beautiful.xforeground,
      normal_bg = beautiful.nord3,
      animate_size = false,
      font = beautiful.font,
      size = 12,
      on_release = function()
        pomodoro.selected_topic = v
        pomodoro.current_state = "select_time"
        redraw_widget()
      end
    })
    buttons.children[1]:add(button)
  end
  buttons.children[1]:add(back_button)
  return buttons
end

local function ui_select_topic()
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text("Select topic", beautiful.xforeground),
      font = beautiful.header_font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  local widget = wibox.widget({
    {
      header,
      create_topic_buttons(),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  local box_container = wibox.container.background()
  box_container.bg = beautiful.dash_widget_bg 
  box_container.forced_height = dpi(350)
  box_container.forced_width = dpi(300)
  box_container.shape = gears.shape.rounded_rect
  local widget_cont = wibox.widget({
    {
      {
        widget,
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      widget = box_container,
    },
    margins = dpi(10),
    color = "#FF000000",
    widget = wibox.container.margin,
  })

  return widget_cont
end


-- █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀   ▀█▀ █ █▀▄▀█ █▀▀
-- ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░   ░█░ █ █░▀░█ ██▄
local function create_time_buttons()
  local buttons = wibox.widget({
    {
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    margins = dpi(20),
    widget = wibox.container.margin,
  })

  local back_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "select_topic"
      redraw_widget()
    end
  })


  for i,v in ipairs(pomodoro.times) do
    local button = widgets.button.text.normal({
      text = v,
      text_normal_bg = beautiful.xforeground,
      normal_bg = beautiful.nord3,
      animate_size = false,
      font = beautiful.font,
      size = 12,
      on_release = function()
        local time = string.gsub(v, "[^0-9.-]", "")
        pomodoro.selected_time = time * 60
        local formatted_time = string.format("%.0f", (pomodoro.selected_time / 60))
        pomodoro.current_state = "tick"
        redraw_widget()
        awful.spawn("timew start " .. pomodoro.selected_topic)
        naughty.notification {
          app_name = "Pomodoro",
          title = "Pomodoro started",
          message = "Work on " .. pomodoro.selected_topic .. " for " .. formatted_time .. "m",
          timeout = 5,
        }
      end
    })
    buttons.children[1]:add(button)
  end
  buttons.children[1]:add(back_button)
  return buttons
end

local function ui_select_time()
  local header = wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text("Select time", beautiful.xforeground),
      font = beautiful.header_font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })

  local widget = wibox.widget({
    {
      header,
      create_time_buttons(),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
  
  local box_container = wibox.container.background()
  box_container.bg = beautiful.dash_widget_bg 
  box_container.forced_height = dpi(350)
  box_container.forced_width = dpi(300)
  box_container.shape = gears.shape.rounded_rect
  local widget_cont = wibox.widget({
    {
      {
        widget,
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      widget = box_container,
    },
    margins = dpi(10),
    color = "#FF000000",
    widget = wibox.container.margin,
  })

  return widget_cont
end


--▀█▀ █ █▀▀ █▄▀
--░█░ █ █▄▄ █░█
local function ui_tick()
  -- UI for the timer
  local timer = wibox.widget({
    {
      {
        id = "textbox",
        widget = wibox.widget.textbox,
        markup = helpers.ui.colorize_text("00:00", beautiful.xforeground),
        font = beautiful.header_font_name .. "Light 30",
        align = "center",
        valign = "center",
      },
      id = "bar",
      value = 100,
      max_value = 100,
      min_value = 0,
      color = beautiful.pomodoro_bar_fg,
      border_color = beautiful.pomodoro_bar_bg,
      border_width = dpi(3),
      forced_height = dpi(150),
      forced_width = dpi(150),
      widget = wibox.container.radialprogressbar,
    },
    widget = wibox.container.place,
  })

  -- Backend stuff for timer
  function format_ui_time(time_remaining)
    local min_remaining = math.floor(time_remaining / 60, 1)
    if min_remaining < 10 then
      min_remaining = "0" .. tostring(min_remaining)
    end
    local sec_remaining = time_remaining % 60
    if sec_remaining < 10 then
      sec_remaining = "0" .. tostring(sec_remaining)
    end
    local text = min_remaining .. ":" .. sec_remaining
    return text
  end

  -- Run the timer
  local second_timer
  function timer_tick(time)
    local ui_text = timer:get_children_by_id("textbox")[1]
    local ui_bar = timer:get_children_by_id("bar")[1]
    local start_time = tonumber(time)
    pomodoro.time_remaining = start_time
   
    -- Run this once first to set starting time
    local text = format_ui_time(pomodoro.time_remaining)
    ui_text:set_markup_silently(helpers.ui.colorize_text(text, beautiful.xforeground))

    -- Ticks every 1 second
    -- Updates progress bar ui
    second_timer = gears.timer {
      timeout = 1,
      call_now = false,
      autostart = false,
      callback = function()
        pomodoro.time_remaining = pomodoro.time_remaining - 1
       
        -- Update text time
        text = format_ui_time(pomodoro.time_remaining)
        ui_text:set_markup_silently(helpers.ui.colorize_text(text, beautiful.xforeground))

        -- Update progress bar
        local progress = (pomodoro.time_remaining * 100) / pomodoro.selected_time
        ui_bar.value = progress

        if pomodoro.time_remaining <= 0 then
          local formatted_time = string.format("%.0f", (pomodoro.selected_time / 60))
          naughty.notification {
            app_name = "Pomodoro",
            title = "Pomodoro completed!",
            message = "Finished " .. formatted_time .. "m of work on " .. pomodoro.selected_topic,
            timeout = 0,
          }
          local sound = gfs.get_configuration_dir() .. "theme/assets/pomo_complete.mp3"
          awful.spawn.easy_async("mpg123 " .. sound, function() end)
          awful.spawn.easy_async("timew stop " .. pomodoro.selected_topic, function() end)
          pomodoro.current_state = "complete"
          redraw_widget()
          second_timer:stop()
        end
      end,
    }

    pomodoro.timer_state = "ticking"
    second_timer:start()
  end

  -- Timer actions
  local timer_buttons = wibox.widget({
    {
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })

  local timer_pause_button, timer_play_button, timer_stop_button
  timer_pause_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord3,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      timer_buttons.children[1]:remove(1)
      timer_buttons.children[1]:insert(1, timer_play_button)
      awful.spawn("timew stop " .. pomodoro.selected_topic)
      pomodoro.timer_state = "paused"
      second_timer:stop()
    end
  })
  
  timer_play_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord3,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      timer_buttons.children[1]:remove(1)
      timer_buttons.children[1]:insert(1, timer_pause_button)
      awful.spawn("timew start " .. pomodoro.selected_topic)
      pomodoro.timer_state = "ticking"
      second_timer:start()
    end
  })
  
  timer_stop_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord3,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.timer_state = "stopped"
      awful.spawn("timew stop " .. pomodoro.selected_topic)
      second_timer:stop()
      reset_pomodoro()
      redraw_widget()
    end
  })

  function create_timer_buttons()
    timer_buttons.children[1]:insert(1, timer_pause_button)
    timer_buttons.children[1]:insert(2, timer_stop_button)
    return timer_buttons
  end

  -- UI for timer
  local description = wibox.widget({
    {
      markup = helpers.ui.colorize_text("CURRENT TASK", beautiful.nord3),
      font = beautiful.font_name .. "Bold 10", 
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    {
      markup = helpers.ui.colorize_text(pomodoro.selected_topic, beautiful.xforeground),
      font = "Roboto 15",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.vertical,
  })
  
  -- Start timer!
  if pomodoro.preserved == "true" then
    timer_tick(pomodoro.time_remaining)
  else
    timer_tick(pomodoro.selected_time)
  end
      
  -- Save current state in xrdb on restart
  awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then
      awful.spawn.with_shell('echo "pomodoro.current_state: ' .. pomodoro.current_state .. 
        '\npomodoro.selected_topic: ' .. pomodoro.selected_topic .. 
        '\npomodoro.selected_time: ' .. pomodoro.selected_time .. 
        '\npomodoro.time_remaining: ' .. pomodoro.time_remaining .. 
        '\npomodoro.timer_state: ' .. pomodoro.timer_state .. 
        '\npomodoro.preserved: true' ..
        '" | xrdb -merge')
    end
  end)

  -- Assemble pomodoro widget
  create_timer_buttons()
  local widget = wibox.widget({
    {
      description,
      timer,
      timer_buttons,
      spacing = dpi(15),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  
  local box_container = wibox.container.background()
  box_container.bg = beautiful.dash_widget_bg 
  box_container.forced_height = dpi(350)
  box_container.forced_width = dpi(300)
  box_container.shape = gears.shape.rounded_rect
  local widget_cont = wibox.widget({
    {
      {
        widget,
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      widget = box_container,
    },
    margins = dpi(10),
    color = "#FF000000",
    widget = wibox.container.margin,
  })
  return widget_cont
end


--█▀▀ █▀█ █▀▄▀█ █▀█ █░░ █▀▀ ▀█▀ █▀▀
--█▄▄ █▄█ █░▀░█ █▀▀ █▄▄ ██▄ ░█░ ██▄
local function ui_complete()
  local back_to_beginning = widgets.button.text.normal({
    text = "take it back now yall",
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.nord3,
    animate_size = false,
    font = beautiful.header_font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "start"
      redraw_widget()
    end
  })

  local formatted_time = string.format("%.0f", (pomodoro.selected_time / 60))
  local text = "finished " .. formatted_time .. "m of work on " .. pomodoro.selected_topic
  local ugh = wibox.widget({
    {
      {
        markup = helpers.ui.colorize_text("the horror is over", beautiful.xforeground),
        font = beautiful.header_font_name .. "20",
        widget = wibox.widget.textbox,
        align = "center",
        valign = "center",
      },
      {
        markup = helpers.ui.colorize_text(text, beautiful.xforeground),
        widget = wibox.widget.textbox,
        font = beautiful.header_font_name .. "12",
        align = "center",
        valign = "center",
      },
      back_to_beginning,
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  local box_container = wibox.container.background()
  box_container.bg = beautiful.dash_widget_bg 
  box_container.forced_height = dpi(350)
  box_container.forced_width = dpi(300)
  box_container.shape = gears.shape.rounded_rect
  local widget_cont = wibox.widget({
    {
      {
        ugh,
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      widget = box_container,
    },
    margins = dpi(10),
    color = "#FF000000",
    widget = wibox.container.margin,
  })
  return widget_cont
end

------------------

function redraw_widget()
  local current_state = pomodoro.current_state

  local new_content 
  if current_state == "start" then
    new_content = ui_start()
  elseif current_state == "select_topic" then
    new_content = ui_select_topic()
  elseif current_state == "select_time" then
    new_content = ui_select_time()
  elseif current_state == "tick" then
    new_content = ui_tick()
  elseif current_state == "complete" then
    new_content = ui_complete()
  end
 
  widget:set_widget(new_content)
end
      
-- If awesome was restarted, preserve stuff
awful.spawn.easy_async_with_shell("xrdb -query", 
  function(stdout)
    local preserved = stdout:match('pomodoro.preserved:%s+%w+')
    if preserved then
      pres = string.gsub(preserved, 'pomodoro.preserved:', '')
      pres = string.gsub(pres, '\t', '')
      pomodoro.preserved = pres

      pomo_state = stdout:match('pomodoro.current_state:%s+%a+')
      pomo_state = string.gsub(pomo_state, 'pomodoro.current_state:', '')
      pomo_state = string.gsub(pomo_state, '\t', '')
      pomodoro.current_state = pomo_state
      
      topic = stdout:match('pomodoro.selected_topic:%s+%a+')
      topic = string.gsub(topic, 'pomodoro.selected_topic:', '')
      topic = string.gsub(topic, '\t', '')
      pomodoro.selected_topic = topic
      
      sel_time = stdout:match('pomodoro.selected_time:%s+%d+')
      sel_time = tonumber(sel_time:match('%d+'))
      pomodoro.selected_time = sel_time

      remaining = stdout:match('pomodoro.time_remaining:%s+%d+')
      remaining = tonumber(remaining:match('%d+'))
      pomodoro.time_remaining = remaining

      --timer_state = stdout:match('pomodoro.timer_state:%s+%a+')
      --pomodoro.timer_state = "paused"

      redraw_widget()
    else
      redraw_widget()
    end
  end)

return widget
