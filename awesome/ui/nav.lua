
-- █▄░█ ▄▀█ █░█ █▀▀ █░░ ▄▀█ █▀ █▀ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▄▄ █▄▄ █▀█ ▄█ ▄█ ██▄ ▄█ 

-- Class definitions for making widgets navigable
-- with the keyboard

-- Things that are selectable:
--    - dash widgets
--    - textbox thingy (like habits)
--    - elevated button thingy

local beautiful = require("beautiful")
local naughty = require("naughty")

-- █▄▄ ▄▀█ █▀ █▀▀ 
-- █▄█ █▀█ ▄█ ██▄ 
-- Only responsible for defining signals and basic vars
-- Functions must be overridden in derived classes
local Base = {
  widget      = nil,
  name        = nil,
  selected    = false,
  highlighted = false,
}

function Base:hl_toggle() end
function Base:release()   end

function Base:new(widget, name)
  local o = {}
  o.widget  = widget
  o.name    = name or "noname"

  local highlight_signal = "nav::" .. o.name .. "::hl_toggle"
  awesome.connect_signal(highlight_signal, function()
    o:hl_toggle()
  end)

  local release_signal = "nav::" .. o.name .. "::release"
  awesome.connect_signal(release_signal, function()
    o:release()
  end)

  setmetatable(o, self)
  self.__index = self
  return o
end

-- ELEVATED BUTTON 
local Elevated = Base:new(widget, name)

function Elevated:hl_toggle()
  print("hl toggle: " .. self.name)
  self.highlighted = not self.highlighted
  if self.highlighted then
    self.widget:set_color("#bf616a")
  else
    self.widget:set_color(beautiful.fg)
  end
end

function Elevated:release()
  print("release: " .. self.name)
  self.widget:nav_release()
end

local nav = {
  Base      = Base,
  Elevated  = Elevated,
}

-- testing shit
local Account = {
  balance = 0,
  str     = "noname",
}
function Account:new(str)
  local o = {}
  o.str = str or "noname"
  setmetatable(o, self)
  self.__index = self
  return o
end

function Account:print()
  print(self.str)
end

local fuck = Account:new("noname")
fuck:print()

local Derived = Account:new()
function Derived:print()
  print(self.str .. " test!")
end

local d = Derived:new("fuck")
d:print()

return nav
