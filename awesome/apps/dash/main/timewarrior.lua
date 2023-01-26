
-- ▀█▀ █ █▀▄▀█ █▀▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- ░█░ █ █░▀░█ ██▄ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

-- Starts/stops Timewarrior time tracking.

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colorize = require("helpers").ui.colorize_text
local simplebtn = require("helpers").ui.simple_button
local box = require("helpers").ui.create_boxed_widget
local dash_header = require("helpers").ui.create_dash_widget_header
local dash = require("core.cozy.dash")
local time = require("core.system.time")
local format_time = require("helpers.core").format_time

local navbg = require("modules.keynav.navitem").Background
local area  = require("modules.keynav.area")

local nav_timewarrior = area({ name = "timewarrior" })

local timew_widget

--- Creates a subsection with a header.
-- Subsections used: current session, working on, total today
local function create_ui_subsection(header, text, text_size)
  local _header = wibox.widget({
    markup = colorize(header, beautiful.timew_header_fg),
    font   = beautiful.base_small_font,
    valign = "center",
    align  = "center",
    widget = wibox.widget.textbox,
  })

  local _text = wibox.widget({
    markup = colorize(text, beautiful.fg),
    font   = beautiful.alt_font_name .. text_size,
    valign = "center",
    align  = "center",
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    _header,
    _text,
    layout = wibox.layout.fixed.vertical,
    -------
    set_text = function(self, new_text)
      self.children[2]:set_markup_silently(colorize(new_text, beautiful.fg))
    end
  })
end

local total_all_tags = create_ui_subsection("TOTAL TODAY", "--", 15)
local current_time   = create_ui_subsection("CURRENT SESSION", "--", 30)
local current_tag    = create_ui_subsection("WORKING ON", "--", 15)

function total_all_tags:update()
  local cmd = "timew sum | tail -n 2"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    total_all_tags:set_text(format_time(stdout))
  end)
end

function current_time:update()
  local cmd = "timew | tail -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    current_time:set_text(format_time(stdout))
  end)
end

function current_tag:update()
  local cmd = "timew | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tag = string.gsub(stdout, "Tracking ", "")
    tag = string.gsub(tag, "%s+.+$", "")
    self:set_text(tag)
  end)
end


-- █▀ ▀█▀ █▀█ █▀█ █▀█ █▀▀ █▀▄ 
-- ▄█ ░█░ █▄█ █▀▀ █▀▀ ██▄ █▄▀ 

local ui_stopped = wibox.widget({
  wibox.widget({
    markup = colorize("No active time tracking.", beautiful.fg),
    valign = "center",
    align  = "center",
    widget = wibox.widget.textbox,
  }),
  total_all_tags,
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

-- █▀ ▀█▀ ▄▀█ █▀█ ▀█▀ █▀▀ █▀▄ 
-- ▄█ ░█░ █▀█ █▀▄ ░█░ ██▄ █▄▀ 

local stop_button = simplebtn({
  text = "Stop",
  bg   = beautiful.timew_btn_bg,
  width   = dpi(100),
  margins = {
    left   = dpi(15),
    right  = dpi(15),
    top    = dpi(10),
    bottom = dpi(10),
  },
})

local nav_stop = navbg({
  widget  = stop_button.children[1],
  bg_on   = beautiful.bg_l3,
  bg_off  = beautiful.timew_btn_bg,
  release = function()
    awful.spawn.with_shell("timew stop")
    awful.spawn.with_shell("echo 'all' | task status:pending stop")
    nav_timewarrior:remove_all_items()
    time:emit_signal("set_tracking_inactive")
    timew_widget:set(ui_stopped)
  end
})

local ui_started = wibox.widget({
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

-----------------------

local function update_timew_information()
  current_tag:update()
  total_all_tags:update()
  current_time:update()
end

-- Final assembly of widget
timew_widget = wibox.widget({
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
  -------------
  set = function(self, widget)
    local content = self:get_children_by_id("content")[1]
    content:set(1, widget)
  end
})

-- Check timew output and set widget state accordingly
local function read_timew_state()
  local cmd = "timew | tail -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout:find("no active time tracking") then
      total_all_tags:update()
      timew_widget:set(ui_stopped)
      nav_timewarrior:remove_all_items()
      nav_timewarrior:reset()
    else
      update_timew_information()
      timew_widget:set(ui_started)
      nav_timewarrior:append(nav_stop)
    end
  end)
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- NOTE: I don't know why this is here, I don't think this is necessary
-- Emitted by Timewarrior hook
-- awesome.connect_signal("dash::update_timew", function()
--   read_timew_state()
-- end)

-- Update widget whenever dashboard is opened
dash:connect_signal("setstate::open", function()
  read_timew_state()
end)

local container = box(timew_widget, dpi(0), dpi(320), beautiful.dash_widget_bg)

return function()
  return container, nav_timewarrior
end

