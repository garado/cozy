
-- █▀█ █░█ █ █▀▀ █▄▀   ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ▀▀█ █▄█ █ █▄▄ █░█   █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty = require("naughty")
local helpers = require("helpers")
local widgets = require("ui.widgets")
local gfs = require("gears.filesystem")
local apps = require("configuration.apps")
local Area = require("modules.keynav.area")
local control = require("core.cozy.control")
local Qaction = require("modules.keynav.navitem").Qaction

local nav_qactions = Area:new({
  name = "qactions",
  is_row = true,
  is_grid_container = true,
  circular = true,
})

local scripts = gfs.get_configuration_dir() .. "utils/ctrl/"
local term = apps.default.terminal
local qaction_header

-- █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 
-- A bunch of functions that the quick actions call.

-- Helper functions
local function qa_notify(title, msg, timeout)
  naughty.notification {
    app_name = "Quick actions",
    title = title,
    message = msg,
    timeout = timeout or 2,
  }
end

-- rotate from portrait to landscape
local function rotate_screen_func()
  -- gets current screen orientation
  -- works on my machine ¯\_(ツ)_/¯
  local cmd =  "xrandr --query | head -n 2 | tail -n 1 | cut -d ' ' -f 5"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local orientation
    if stdout:find("normal") then
      orientation = "left"
    else
      orientation = "normal"
    end
    local rotate_cmd = scripts .. "rotate_screen " .. orientation
    awful.spawn(rotate_cmd)
  end)
end

-- lenovo laptops have a conservation mode that
-- stops the battery from charging when it hits 55-60%
local function consmode_func()
  local cmd = "ideapad-cm status"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local cm_cmd
    local status
    if string.find(stdout, "enabled") then
      cm_cmd = "ideapad-cm disable"
      status = "disabled"
    else
      cm_cmd = "ideapad-cm enable"
      status = "enabled"
    end
    qa_notify("Conservation mode", "Conservation mode " .. status)
    awful.spawn(cm_cmd)
  end)
end

local function onboard_func()
  awful.spawn.once("onboard")
  control:toggle()
end

-- spawn floating term window
-- i just use python as calculator 
local function calculator_func()
  awful.spawn(term .. " -e python", {
    floating  = true,
    ontop     = true,
    sticky    = true,
    tag       = mouse.screen.selected_tag,
    placement = awful.placement.bottom_right,
    width = 600,
    height = 400,
  })
  control:toggle()
end

-- Toggle redshift
local function nightshift_func()
  local lat = 32
  local long = -122
  local cmd = "pidof redshift"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local message
    local redshift_active = stdout ~= ""
    if redshift_active then
      awful.spawn.with_shell("pkill redshift")
      message = "Disabled"
    else
      local coords = lat .. ":" .. long
      awful.spawn.with_shell("redshift -l " .. coords)
      message = "Enabled"
    end
    qa_notify("Nightshift", message)
  end)
end

-- Helper function to create a quick action button
local function create_quick_action(icon, name, func, area)
  local quick_action = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.ctrl_qa_btn_bg,
    animate_size = false,
    size = 20,
    on_release = function()
      if func then func() end
    end,
    on_hover = function()
      local markup = string.upper(name)
      markup = helpers.ui.colorize_text(markup, beautiful.ctrl_header_fg)
      qaction_header:set_markup_silently(markup)
    end
  })

  local action = wibox.widget({
    {
      quick_action,
      forced_width = dpi(50),
      forced_height = dpi(50),
      widget = wibox.container.margin,
    },
    widget = wibox.container.place,
  })

  area:append(Qaction:new(quick_action))
  return action
end

-- █░█ █ 
-- █▄█ █ 

local row1 = Area:new({
  name = "qaction_row1",
  is_row = true,
  group_name = "nav_qactions",
  circular = true,
})

local row2 = Area:new({
  name = "qaction_row2",
  is_row = true,
  group_name = "nav_qactions",
  circular = true,
})

-- Restore quick action header when leaving the area
awesome.connect_signal("nav::area_changed", function(last_area_name)
  local valid_areas = {
    ["qactions"]      = true,
    ["qactions_row1"] = true,
    ["qactions_row2"] = true,
  }
  local selected = nav_qactions.selected
  if not selected and not valid_areas[last_area_name] or last_area_name == "" then
    local markup = helpers.ui.colorize_text("QUICK ACTIONS", beautiful.ctrl_header_fg)
    qaction_header:set_markup_silently(markup)
  end
end)

qaction_header = wibox.widget({
  markup = helpers.ui.colorize_text("QUICK ACTIONS", beautiful.ctrl_header_fg),
  align = "center",
  valign = "center",
  font = beautiful.font_name .. "10",
  widget = wibox.widget.textbox,
})

local function incomplete()
  qa_notify("Oops!", "This quick action hasn't been implemented yet.", 5)
end

-- Creating the quick action buttons
local qactions = wibox.widget({
  {
    qaction_header,
    {
      -- create_quick_action arguments:
      -- icon name function navarea
      create_quick_action("", "Rotate", rotate_screen_func, row1),
      create_quick_action("", "Conservation mode", consmode_func, row1),
      create_quick_action("", "Onboard", onboard_func, row1),
      create_quick_action("", "Calculator", calculator_func, row1),
      create_quick_action("", "Nightshift", nightshift_func, row1),

      -- unfinished --
      create_quick_action("", "Timer", incomplete, row2),
      create_quick_action("便", "Rotate bar", incomplete, row2),
      create_quick_action("", "Journal", incomplete, row2),
      create_quick_action("", "Eyebleach", incomplete, row2),
      create_quick_action("", "Do not disturb", incomplete, row2),

      spacing = dpi(15),
      forced_num_rows = 2,
      forced_num_cols = 5,
      homogeneous = true,
      layout = wibox.layout.grid,
    },
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

nav_qactions:append(row1)
nav_qactions:append(row2)

return function()
  return nav_qactions, qactions
end
