
-- █▀▀ █ ▀█▀    █▄▄ ▄▀█ █▀▀ █▄▀ █░█ █▀█ 
-- █▄█ █ ░█░    █▄█ █▀█ █▄▄ █░█ █▄█ █▀▀ 

-- Auto push changes to a repo.
-- Useful if you use Git to back up documents and need to quickly sync
-- them between devices.

local wibox = require("wibox")
local beautiful = require("beautiful")
local helpers = require("helpers")
local user_vars = require("user_variables")
local awful = require("awful")
local naughty = require("naughty")

local button = wibox.widget({
  markup = helpers.ui.colorize_text("", beautiful.wibar_launch_app),
  widget = wibox.widget.textbox,
  font = beautiful.font .. "12",
  align = "center",
  valign = "center",
})

local function notify(msg)
  naughty.notification {
    app_name = "System notification",
    title = "Git backup",
    message = msg,
  }
end

local function parse_push_stdout(stdout)
end

local function parse_pull_stdout(stdout)
end

local function push()
  local name = user_vars.git[1].name
  local repo = user_vars.git[1].repo
  local msg = user_vars.git[1].msg
  local cmd = "cd " .. repo .. " ; git add * ; git commit -m '" .. msg .. "'; git push"
  notify("Backing up " .. name)
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    local parsed_stdout = parse_push_stdout(stdout)
    naughty.notification {
      message = stdout,
      title = stderr,
      timeout = 0,
    }
  end)
end

local function pull()
  local repo = user_vars.git[1].repo
  local msg = user_vars.git[1].msg
  local name = user_vars.git[1].name
  local cmd = "cd " .. repo .. " ; git pull"
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    local parsed_stdout = parse_pull_stdout(stdout)
    naughty.notification {
      message = stdout,
      title = stderr,
      timeout = 0,
    }
  end)
end

button:connect_signal("button::press", function()
  --pull()
  push()
end)

button:connect_signal("mouse::enter", function()
  local markup = helpers.ui.colorize_text("", beautiful.wibar_launch_hover)
  button:set_markup_silently(markup)
end)

button:connect_signal("mouse::leave", function()
  local markup = helpers.ui.colorize_text("", beautiful.wibar_launch_app)
  button:set_markup_silently(markup)
end)

return button
