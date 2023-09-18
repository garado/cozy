
-- █▀ █▄█ █▀ ▀█▀ █▀█ ▄▀█ █▄█
-- ▄█ ░█░ ▄█ ░█░ █▀▄ █▀█ ░█░

-- Only one systray widget can exist at any given time, which is a problem 
-- if you're on a multi-monitor setup with multiple bars.
-- This is some bullshit to make the systray show only on the focused screen.

-- This module contains the actual systray widget.
-- Each screen's bar has a systray container.
-- When each systray container's toggle button is clicked, it makes a request to 
-- this module for the systray widget.
-- The systray widget is given to only the container on the focused screen.

local gtable  = require("gears.table")
local gobject = require("gears.object")
local awful = require("awful")
local wibox = require("wibox")
local conf  = require("cozyconf")
local ui    = require("utils.ui")
local dpi   = ui.dpi

local systray_control = {}

local instance = nil

function systray_control:new()
  self.widget = wibox.widget({
    horizontal = not (conf.bar_style == "vbar"),
    base_size = dpi(20),
    widget = wibox.widget.systray,
  })
  return systray_control
end

function systray_control:request_tray(tray_container, screen)
  if awful.screen.focused().name == screen.name then
    if self.active_container and not (self.active_container == tray_container) then
      self.active_container:reset()
      self.active_container:force_close()
    end

    self.widget.screen = screen
    tray_container.widget = self.widget

    tray_container:toggle_systray(self.widget.num_entries or 0)

    self.active_container = tray_container
  end
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, systray_control, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then instance = new() end
return instance
