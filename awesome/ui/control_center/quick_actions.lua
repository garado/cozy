
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
local Area = require("ui.nav.area")
local Qaction = require("ui.nav.navitem").Qaction

local nav_qactions = Area:new({ name = "qactions" })

local scripts = gfs.get_configuration_dir() .. "utils/ctrl/"
local term = apps.default.terminal
local qaction_header

-- █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 
-- A bunch of functions that the quick actions call.

-- Helper functions
local function qa_notify(title, msg)
  naughty.notification {
    app_name = "Quick actions",
    title = title,
    message = msg,
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
local function conservation_mode_func()
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
  awesome.emit_signal("control_center::toggle")
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
  awesome.emit_signal("control_center::toggle")
end

-- Controls picom settings
local picom_settings = {"max", "med", "min", "off"}
local picom_settings_current = 1
local function picom_func()
  qa_notify("Picom", picom_settings[picom_settings_current])
  picom_settings_current = (picom_settings_current + 1) % #picom_settings
  if picom_settings_current == 0 then picom_settings_current = #picom_settings end
end

-- Helper function to create a quick action button
local function create_quick_action(icon, name, func)
  local quick_action = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.fg,
    normal_bg = beautiful.ctrl_qa_btn_bg,
    animate_size = false,
    size = 20,
    on_release = function()
      func()
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

  nav_qactions:append(Qaction:new(quick_action))
  return action
end

-- █░█ █ 
-- █▄█ █ 

-- restore qaction header when leaving the area
awesome.connect_signal("nav::area_changed", function(last_area_name)
  if last_area_name == "qactions" then
    local text = helpers.ui.colorize_text("QUICK ACTIONS", beautiful.ctrl_header_fg)
    qaction_header:set_markup_silently(text)
  end
end)

qaction_header = wibox.widget({
  markup = helpers.ui.colorize_text("QUICK ACTIONS", beautiful.ctrl_header_fg),
  align = "center",
  valign = "center",
  font = beautiful.font_name .. "10",
  widget = wibox.widget.textbox,
})

-- Creating the quick action buttons
-- Arguments: icon name func 
local qactions = wibox.widget({
  {
    qaction_header,
    {
      create_quick_action("", "Rotate", rotate_screen_func),
      create_quick_action("", "Conservation mode", conservation_mode_func),
      create_quick_action("", "Onboard", onboard_func),
      create_quick_action("", "Calculator", calculator_func),
      create_quick_action("", "Animations", picom_func),

      -- unfinished --
      create_quick_action("", "Timer", ""),
      create_quick_action("", "Nightshift", ""),
      create_quick_action("", "Rotate bar", ""),
      create_quick_action("", "Screenshot", ""),
      create_quick_action("", "Mic", ""),

      -- 
      --  

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

return function()
  return nav_qactions, qactions
end
