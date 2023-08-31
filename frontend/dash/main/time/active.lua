
-- ▄▀█ █▀▀ ▀█▀ █ █░█ █▀▀    █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ 
-- █▀█ █▄▄ ░█░ █ ▀▄▀ ██▄    ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local timew = require("backend.system.time")

local _time = ui.textbox({
  text  = "Cozy:General",
  align = "center",
  font  = beautiful.font_reg_m,
})

local session_time = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "Focus",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  _time,
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

--------------

local _task = ui.textbox({
  text  = "[Feat] Change sort option (alphabetical/duedate+alpha)",
  align = "center",
  font  = beautiful.font_reg_s,
})

local _task_scroll = wibox.widget({
  _task,
  step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
  speed  = 100,
  fps    = 40,
  layout = wibox.container.scroll.horizontal,
})

local session_task = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "Task",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  {
    _task_scroll,
    left  = dpi(25),
    right = dpi(25),
    widget = wibox.container.margin,
  },
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

--------------

local _details = ui.textbox({
  text  = "42m",
  align = "center",
  font  = beautiful.font_reg_m,
})

local session_details = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "This Session",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  _details,
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

--------------

local _total = ui.textbox({
  text = "2h 55m",
  align = "center",
  font  = beautiful.font_reg_m,
})

local total_today = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "Total Today",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  _total,
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

-------------

local stop = btn({
  text  = "Stop",
  bg    = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
  width = dpi(100),
  on_release = function()
    timew:stop()
  end
})

local active = wibox.widget({
  session_time,
  session_task,
  {
    {
      session_details,
      total_today,
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  {
    stop,
    widget = wibox.container.place,
  },
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█

timew:connect_signal("tracking::active", function()
  _time:update_text(timew.tracking.title)
end)

return active
