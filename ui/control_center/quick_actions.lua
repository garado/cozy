
-- █▀█ █░█ █ █▀▀ █▄▀   ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ▀▀█ █▄█ █ █▄▄ █░█   █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local naughty = require("naughty")
local widgets = require("ui.widgets")
local gfs = require("gears.filesystem")

local scripts = gfs.get_configuration_dir() .. "utils/ctrl/"

local function qa_notify(title, msg)
  naughty.notification {
    app_name = "Quick actions",
    title = title,
    message = msg,
  }
end

-- A bunch of functions that each quick action is going to call.

-- there is certainly a better way handle orientation state
-- BUT i am lazy right now!
local screen_is_normal = true
local function rotate_screen_func()
  local orientation
  if screen_is_normal then 
    orientation = "left"
  else
    orientation = "normal"
  end
  screen_is_normal = not screen_is_normal

  local cmd = scripts .. "rotate_screen " .. orientation
  awful.spawn.easy_async(cmd)
end

local function conservation_mode_func()
  local cmd = "ideapad-cm status"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local cmd
    local status
    if string.find(stdout, "enabled") then
      cmd = "ideapad-cm disable"
      status = "disabled"
    else
      cmd = "ideapad-cm enable"
      status = "enabled"
    end
    qa_notify("Conservation mode", "Conservation mode " .. status)
    awful.spawn.easy_async(cmd)
  end)
end

---

-- Helper function to create a quick action button
local function create_quick_action(icon, name, func)
  local quick_action = widgets.button.text.normal({
    text = icon,
    text_normal_bg = beautiful.xforeground,
    normal_bg = beautiful.wibar_bg,
    animate_size = false,
    size = 20,
    -- why doesn't on_release = func() work?
    on_release = function()
      func()
    end,
  })
  return wibox.widget({
    quick_action,
    widget = wibox.container.place,
  })
end

-- Creating the quick action buttons
-- Arguments: icon name func 
local widget = wibox.widget({
  create_quick_action("", "Rotate", rotate_screen_func),
  create_quick_action("c", "Conservation mode", conservation_mode_func), 
  --
  create_quick_action("c", "Calculator", ""),
  create_quick_action("a", "Airplane mode", ""),
  create_quick_action("", "DND", ""),
  -- 
  --  
  --
  layout = wibox.layout.fixed.vertical,
})

return widget
