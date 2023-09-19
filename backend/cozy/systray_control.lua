
-- █▀ █▄█ █▀ ▀█▀ █▀█ ▄▀█ █▄█
-- ▄█ ░█░ ▄█ ░█░ █▀▄ █▀█ ░█░

-- Only one systray widget can exist at any given time, which is a problem 
-- if you're on a multi-monitor setup with multiple bars.
-- This module makes the systray show only on the focused screen.

--                   ┌───────────────┐
--                   │  THIS MODULE  │◄── systray widget created here
--                   └───────────────┘
--                         ▲ ▲ ▲               
--                         │ │ │                      when the systray needs to be opened,
--           ┌────────────REQUEST────────────┐        all bars on all screens ask this module for the tray.
--           │               │               │        this module removes the tray from the bar it was
--     ┌─────────┐      ┌─────────┐     ┌─────────┐   previously on, then gives it to only the bar on the
--     │  BAR 1  │      │  BAR 2  │     │  BAR 3  │   focused screen.
--     │(Screen1)│      │(Screen2)│     │(Screen3)│
--     └─────────┘      └─────────┘     └─────────┘

local be = require("utils.backend")
local awful = require("awful")
local wibox = require("wibox")
local conf = require("cozyconf")
local dpi = require("utils.ui").dpi

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

--- @method request_tray
-- @brief When the systray needs to be opened, each bar calls this function 
--        to request the tray.
-- @param tray_container  a wibox.container.place that the systray widget will be added to
-- @param screen          the screen that the tray container is on
function systray_control:request_tray(tray_container, screen)
  if awful.screen.focused().name == screen.name then
    -- Remove the systray widget from the container it was previously in
    if self.active_container and not (self.active_container == tray_container) then
      self.active_container:reset()
      self.active_container:force_close()
    end

    -- Give it to the container on the focused screen
    self.widget.screen = screen
    tray_container.widget = self.widget

    -- NOTE: num_entries is the number of icons on the systray. It is 
    -- obtained by calling capi.awesome.systray(), but that wasn't working
    -- when called in this file for some reason, so I patched wibox.widget.systray
    -- to expose it.
    -- BUG: num_entries is sometimes only set *after* the first draw
    --      (so the first time the systray is opened, it doesn't show)
    -- tray_container:toggle_systray(self.widget.num_entries or 0)
    tray_container:toggle_systray(awesome.systray() or 0)

    self.active_container = tray_container
  end
end

if not instance then instance = be.create_gobject(systray_control) end
return instance
