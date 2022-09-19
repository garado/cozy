
-- █▀█ █▀█ █▀▄▀█ █▀█ █▀▄ █▀█ █▀█ █▀█
-- █▀▀ █▄█ █░▀░█ █▄█ █▄▀ █▄█ █▀▄ █▄█

-- This widget is unused, buggy, and hasn't been maintained in a while

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
local naughty = require("naughty")
local json = require("modules.json")

local math = math
local string = string

local redraw_ui

local pomodoro = {
  selected_topic = nil,
  timer_time = nil,
  time_remaining = nil,
  preserved = false, -- if pomo state is preserved in xrdb
  states = {
    "start", "select_topic", "select_time", "tick", "complete",
  },
  current_state = "start",
  tick_type = nil,
  tick_types = { "work", "break", },
  timer_state = "stopped",
  timer_states = {
    "stopped", "ticking", "paused",
  },
  topics = user_vars.pomo.topics,
  times = user_vars.pomo.times,
  short_break_duration = user_vars.pomo.short_break,
  long_break_duration = user_vars.pomo.long_break,
  target = user_vars.pomo.target,
  completed = 0,
  min_focused = 0,
}

local function reset_pomodoro()
  pomodoro.current_state = "start"
  pomodoro.selected_topic = nil
  pomodoro.timer_time = nil
  pomodoro.time_remaining = nil
  pomodoro.preserved = false
  timer_state = "stopped"
  pomodoro.tick_type = nil
  awful.spawn.easy_async("xrdb -remove", function() end)
end

local function ui_target_pomos()
  local text = "5" .. "/" .. pomodoro.target .. " pomos completed"
  return wibox.widget({
    align = "center",
    valign = "center",
    markup = helpers.ui.colorize_text(text, beautiful.subtext),
    widget = wibox.widget.textbox,
  })
end

-- ui helper functions
local function create_boxed_widget(widget)
  return wibox.widget({
    {
      {
        widget,
        margins = dpi(15),
        widget = wibox.container.margin,
      },
      bg = beautiful.dash_widget_bg,
      forced_height = dpi(350),
      forced_width = dpi(300),
      shape = gears.shape.rounded_rect,
      widget = wibox.container.background,
    },
    margins = dpi(10),
    color = "#FF000000",
    widget = wibox.container.margin,
  })
end

local function create_header(text)
  return wibox.widget({
    {
      widget = wibox.widget.textbox,
      markup = helpers.ui.colorize_text(text, beautiful.dash_header_fg),
      font = beautiful.font_name .. "Light 20",
      align = "center",
      valign = "center",
    },
    margins = dpi(3),
    widget = wibox.container.margin, 
  })
end

-- █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
-- ▄█ ░█░ █▀█ █▀▄ ░█░
local function ui_start()
  local letsdoit = widgets.button.text.normal({
    text = "Let's do it!",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.subtext,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "select_topic"
      redraw_ui()
    end
  })
 
  local widget = wibox.widget({
    {
      create_header("Get to work!"),
      letsdoit,
      --ui_target_pomos(),
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
      widget = wibox.container.margin,
    },
    widget = wibox.container.place,
  })
   
  return create_boxed_widget(widget)
end -- end ui_start


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
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "start"
      redraw_ui()
    end
  })

  for i,v in ipairs(pomodoro.topics) do
    local button = widgets.button.text.normal({
      text = v,
      text_normal_bg = beautiful.fg,
      normal_bg = beautiful.surface0,
      animate_size = false,
      font = beautiful.font,
      size = 12,
      on_release = function()
        pomodoro.selected_topic = v
        pomodoro.current_state = "select_time"
        redraw_ui()
      end
    })
    buttons.children[1]:add(button)
  end
  buttons.children[1]:add(back_button)
  return buttons
end -- end create_topic_buttons

local function ui_select_topic()
  local widget = wibox.widget({
    {
      create_header("Select topic"),
      create_topic_buttons(),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return create_boxed_widget(widget)
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
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      pomodoro.current_state = "select_topic"
      redraw_ui()
    end
  })

  for i,v in ipairs(pomodoro.times) do
    local button = widgets.button.text.normal({
      text = v,
      text_normal_bg = beautiful.fg,
      normal_bg = beautiful.surface0,
      animate_size = false,
      font = beautiful.font,
      size = 12,
      on_release = function()
        local time = string.gsub(v, "[^0-9.-]", "")
        pomodoro.timer_time = time * 60
        local formatted_time = math.floor(pomodoro.timer_time / 60)
        pomodoro.current_state = "tick"
        pomodoro.tick_type = "work"
        redraw_ui()
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
end -- end create_time_buttons

local function ui_select_time()
  local widget = wibox.widget({
    {
      create_header("Select time"),
      create_time_buttons(),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
  
  return create_boxed_widget(widget)
end

-- ▀█▀ █ █▀▀ █▄▀
-- ░█░ █ █▄▄ █░█
-- used for both regular timer + break timer
local function ui_tick()
  -- ui for the timer
  local timer = wibox.widget({
    {
      {
        {
          {
            id = "textbox",
            widget = wibox.widget.textbox,
            markup = helpers.ui.colorize_text("00:00", beautiful.fg),
            font = beautiful.alt_font_name .. "Light 30",
            align = "center",
            valign = "center",
          },
          direction = "south",
          widget = wibox.container.rotate,
        },
        id = "bar",
        value = pomodoro.timer_time,
        max_value = pomodoro.timer_time,
        min_value = 0,
        color = beautiful.main_accent,
        border_color = beautiful.surface0,
        border_width = dpi(3),
        forced_height = dpi(150),
        forced_width = dpi(150),
        widget = wibox.container.radialprogressbar,
      },
      direction = "south",
      widget = wibox.container.rotate,
    },
    widget = wibox.container.place,
  })

  -- format time_remaining (in seconds) into MM:SS format
  local function format_ui_time(time_rem)
    local min_rem = math.floor(time_rem / 60)
    min_rem = string.format("%02d", min_rem)
    local sec_rem = time_rem % 60
    sec_rem = string.format("%02d", sec_rem)
    return min_rem .. ":" .. sec_rem
  end

  -- run the timer
  local second_timer
  local function timer_tick(time)
    local ui_text = timer:get_children_by_id("textbox")[1]
    local start_time = tonumber(time)
    pomodoro.time_remaining = start_time
   
    -- run this once first to set starting time
    local text = format_ui_time(pomodoro.time_remaining)
    ui_text:set_markup_silently(helpers.ui.colorize_text(text, beautiful.fg))

    local function second_timer_callback()
      pomodoro.time_remaining = pomodoro.time_remaining - 1
    
      -- update text time
      text = format_ui_time(pomodoro.time_remaining)
      text = helpers.ui.colorize_text(text, beautiful.fg)
      ui_text:set_markup_silently(text)

      -- update progress bar
      local ui_bar = timer:get_children_by_id("bar")[1]
      ui_bar.value = pomodoro.time_remaining 

      -- timer expired
      if pomodoro.time_remaining <= 0 then

        local time = math.floor(pomodoro.timer_time / 60)
        if pomodoro.tick_type == "work" then
          naughty.notification {
            app_name = "Pomodoro",
            title = "Pomodoro completed!",
            message = "Finished " .. time .. "m of " .. pomodoro.selected_topic,
            timeout = 0,
          }
          awful.spawn.easy_async("timew stop " .. pomodoro.selected_topic, function() end)
        elseif pomodoro.tick_type == "break" then
          naughty.notification {
            app_name = "Pomodoro",
            title = "Break's over!",
            message = "Finished a " .. time .. "m break",
            timeout = 0,
          }
        end

        second_timer:stop()
        local sound = gfs.get_configuration_dir() .. "theme/assets/pomo_complete.mp3"
        awful.spawn.easy_async("mpg123 " .. sound, function() end)
        pomodoro.current_state = "complete"
        redraw_ui()
      end
    end -- end second_timer_callback

    -- ticks every 1 second & updates progress bar ui
    second_timer = gears.timer {
      timeout = 1,
      call_now = false,
      autostart = false,
      callback = second_timer_callback,
    }

    pomodoro.timer_state = "ticking"
    second_timer:start()
  end -- end timer_tick()

  -- filled later
  local timer_buttons = wibox.widget({
    {
      id = "buttons",
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })

  local timer_play_button, timer_pause_button, timer_stop_button
  timer_pause_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      timer_buttons.children[1]:set(1, timer_play_button)
      awful.spawn("timew stop " .. pomodoro.selected_topic)
      pomodoro.timer_state = "paused"
      second_timer:stop()
    end
  })
  
  timer_play_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      timer_buttons.children[1]:set(1, timer_pause_button)
      awful.spawn("timew start " .. pomodoro.selected_topic)
      pomodoro.timer_state = "ticking"
      second_timer:start()
    end
  })
  
  local timer_stop_button = widgets.button.text.normal({
    text = "",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.surface0,
    size = 12,
    on_release = function()
      pomodoro.timer_state = "stopped"
      awful.spawn("timew stop " .. pomodoro.selected_topic)
      second_timer:stop()
      reset_pomodoro()
      redraw_ui()
    end
  })

  function create_timer_buttons()
    timer_buttons.children[1]:insert(1, timer_pause_button)
    timer_buttons.children[1]:insert(2, timer_stop_button)
    return timer_buttons
  end

  local desc_header_text = ""
  local desc_text = ""
   if pomodoro.tick_type == "work" then
     desc_header_text = "CURRENT TASK"
     desc_text = pomodoro.selected_topic
   elseif pomodoro.tick_type == "break" then
     desc_header_text = ""
     desc_text = "Take a break"
   end

  local description = wibox.widget({
    {
      markup = helpers.ui.colorize_text(desc_header_text, beautiful.subtext),
      font = beautiful.font_name .. "Bold 10", 
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    {
      markup = helpers.ui.colorize_text(desc_text, beautiful.fg),
      font = beautiful.font_name .. "15",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    layout = wibox.layout.fixed.vertical,
  })
  
  -- Start timer!
  if pomodoro.preserved then
    timer_tick(pomodoro.time_remaining)
  else
    timer_tick(pomodoro.timer_time)
  end
      
  -- Save current state in xrdb on restart
  awesome.connect_signal("exit", function(reason_restart)
    if reason_restart then 
      awful.spawn.with_shell('echo "pomodoro.current_state: ' .. pomodoro.current_state .. 
        '\npomodoro.selected_topic: ' .. pomodoro.selected_topic .. 
        '\npomodoro.tick_type: ' .. pomodoro.tick_type .. 
        '\npomodoro.timer_time: ' .. pomodoro.timer_time .. 
        '\npomodoro.time_remaining: ' .. pomodoro.time_remaining .. 
        '\npomodoro.timer_state: ' .. pomodoro.timer_state .. 
        '\npomodoro.preserved:  true' ..
        '" | xrdb -merge')
    end
  end)

  -- Assemble pomodoro widget
  create_timer_buttons()

  local widget = wibox.widget({
    {
      description,
      timer,
      --ui_target_pomos(),
      timer_buttons,
      spacing = dpi(15),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return create_boxed_widget(widget) 
end -- end ui_tick


--█▀▀ █▀█ █▀▄▀█ █▀█ █░░ █▀▀ ▀█▀ █▀▀
--█▄▄ █▄█ █░▀░█ █▀▀ █▄▄ ██▄ ░█░ ██▄
local function ui_complete()
  local back_to_beginning = widgets.button.text.normal({
    text = "Start a new pomodoro",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      reset_pomodoro()
      redraw_ui()
    end
  })

  local take_break = widgets.button.text.normal({
    text = "Take a break",
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.surface0,
    animate_size = false,
    font = beautiful.font,
    size = 12,
    on_release = function()
      reset_pomodoro()
      pomodoro.timer_time = tonumber(pomodoro.long_break_duration * 60)
      local formatted_time = math.floor(pomodoro.timer_time / 60)
      pomodoro.current_state = "tick"
      pomodoro.tick_type = "break"
      redraw_ui()
      naughty.notification {
        app_name = "Pomodoro",
        title = "Break started",
        message = "Take a break for " .. formatted_time .. "m",
        timeout = 5,
      }
    end
  })

  local function buttons()
    if pomodoro.tick_type == "work" then
      return wibox.widget({
        back_to_beginning,
        take_break,
        spacing = dpi(10),
        layout = wibox.layout.fixed.vertical,
      })
    elseif pomodoro.tick_type == "break" then
      return back_to_beginning
    end
  end

  local time = math.floor(pomodoro.timer_time / 60)
  local header_text, text
  if pomodoro.tick_type == "work" then
    header_text = "The horror is over"
    text = "Finished " .. time .. "m of work on " .. pomodoro.selected_topic
  elseif pomodoro.tick_type == "break" then
    header_text = "Break's over :("
    text = "Finished " .. time .. "m break"
  end

  local widget = wibox.widget({
    {
      create_header(header_text),
      {
        markup = helpers.ui.colorize_text(text, beautiful.fg),
        widget = wibox.widget.textbox,
        font = beautiful.font_name .. "12",
        align = "center",
        valign = "center",
      },
      buttons(),
      spacing = dpi(10),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return create_boxed_widget(widget)
end

------------------

local pomodoro_ui = wibox.container.margin()
function redraw_ui()
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
 
  pomodoro_ui:set_widget(new_content)
end
      
-- preserve state in xrdb if awesomewm restarts
awful.spawn.easy_async_with_shell("xrdb -query", 
  function(stdout)
    local preserved = stdout:match('pomodoro.preserved:%s+true')
    if preserved then
      local pres = string.gsub(preserved, 'pomodoro.preserved:', '')
      pres = string.gsub(pres, '\t', '')
      pomodoro.preserved = true

      local pomo_state = stdout:match('pomodoro.current_state:%s+%a+')
      pomo_state = string.gsub(pomo_state, 'pomodoro.current_state:', '')
      pomo_state = string.gsub(pomo_state, '\t', '')
      pomodoro.current_state = pomo_state
      
      local topic = stdout:match('pomodoro.selected_topic:%s+%a+')
      topic = string.gsub(topic, 'pomodoro.selected_topic:', '')
      topic = string.gsub(topic, '\t', '')
      pomodoro.selected_topic = topic
      
      local sel_time = stdout:match('pomodoro.timer_time:%s+%d+')
      sel_time = tonumber(sel_time:match('%d+'))
      pomodoro.timer_time = sel_time
      
      local tick_type = stdout:match('pomodoro.tick_type:%s+%a+')
      tick_type = string.gsub(tick_type, 'pomodoro.tick_type:', '')
      tick_type = string.gsub(tick_type, '\t', '')
      pomodoro.tick_type = tick_type 

      remaining = stdout:match('pomodoro.time_remaining:%s+%d+')
      remaining = tonumber(remaining:match('%d+'))
      pomodoro.time_remaining = remaining

      redraw_ui()
    else
      redraw_ui()
  end
end)

return pomodoro_ui 

