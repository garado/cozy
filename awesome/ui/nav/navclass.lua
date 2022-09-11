
-- █▄░█ ▄▀█ █░█ █▀▀ █░░ ▄▀█ █▀ █▀ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▄▄ █▄▄ █▀█ ▄█ ▄█ ██▄ ▄█ 

-- Class definitions for making widgets navigable
-- with the keyboard

local beautiful = require("beautiful")
local awful = require("awful")
local table = table

-- █▄▄ ▄▀█ █▀ █▀▀ 
-- █▄█ █▀█ ▄█ ██▄ 
-- Only responsible for defining signals and basic vars
-- Functions must be overridden in derived classes
local Navbase = {
  widget        = nil,
  name          = nil,
  selected      = false,
  highlighted   = false,
}

function Navbase:hl_toggle()   end
function Navbase:hl_off()   end
function Navbase:release()     end

function Navbase:new(widget, name)
  local o = {}
  o.widget  = widget
  o.name    = name or "noname"

  local hl_off = "nav::" .. o.name .. "::hl_off"
  awesome.connect_signal(hl_off, function()
    o:hl_off()
  end)

  local hl_toggle = "nav::" .. o.name .. "::hl_toggle"
  awesome.connect_signal(hl_toggle, function()
    o:hl_toggle()
  end)

  local release = "nav::" .. o.name .. "::release"
  awesome.connect_signal(release, function()
    o:release()
  end)

  setmetatable(o, self)
  self.__index = self
  return o
end

-- █▀▀ █░░ █▀▀ █░█ ▄▀█ ▀█▀ █▀▀ █▀▄ 
-- ██▄ █▄▄ ██▄ ▀▄▀ █▀█ ░█░ ██▄ █▄▀ 
local Elevated = Navbase:new(widget, name)

-- Highlight toggle
function Elevated:hl_toggle()
  self.highlighted = not self.highlighted
  local bg = self.widget:get_children_by_id("background_role")[1].bg
  if self.highlighted then
    self.widget:get_children_by_id("background_role")[1].bg = beautiful.overlay0
  else
    self.widget:get_children_by_id("background_role")[1].bg = beautiful.surface0
  end
end

function Elevated:hl_off()
  self.highlighted = false
  self.widget:get_children_by_id("background_role")[1].bg = beautiful.surface0
end

function Elevated:release()
  self.widget:nav_release()
end

-- █▀▄ ▄▀█ █▀ █░█    █░█░█ █ █▀▄ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▄▀ █▀█ ▄█ █▀█    ▀▄▀▄▀ █ █▄▀ █▄█ ██▄ ░█░ ▄█ 
local DashWidget = Navbase:new(widget, name)

function DashWidget:hl_toggle()
end

-- Return classes
return {
  Elevated = Elevated,
}
