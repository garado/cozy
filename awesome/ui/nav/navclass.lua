
-- █▄░█ ▄▀█ █░█ █▀▀ █░░ ▄▀█ █▀ █▀ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▄▄ █▄▄ █▀█ ▄█ ▄█ ██▄ ▄█ 

-- Class definitions for making widgets navigable
-- with the keyboard

local helpers = require("helpers")
local beautiful = require("beautiful")

-- █▄▄ ▄▀█ █▀ █▀▀ 
-- █▄█ █▀█ ▄█ ██▄ 
-- Only responsible for defining basic vars
-- Functions must be overridden in derived classes
local Navbase = {}
function Navbase:new(widget)
  local o = {}
  o.widget  = widget
  o.selected    = false
  o.highlighted = false
  setmetatable(o, self)
  self.__index = self
  return o
end

function Navbase:hl_toggle()  end
function Navbase:hl_off()     end
function Navbase:release()    end

-- █▀▀ █░░ █▀▀ █░█ ▄▀█ ▀█▀ █▀▀ █▀▄ 
-- ██▄ █▄▄ ██▄ ▀▄▀ █▀█ ░█░ ██▄ █▄▀ 
local Elevated = Navbase:new(widget)

function Elevated:hl_toggle()
  self.highlighted = not self.highlighted
  if self.highlighted then
    self.widget:nav_hl_on()
  else
    self.widget:nav_hl_off()
  end
end

function Elevated:hl_off()
  self.highlighted = false
  self.widget:nav_hl_off()
end

function Elevated:release()
  self.widget:nav_release()
end

-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀ 
-- █▀█ █▀█ █▄█ █ ░█░ ▄█ 
local Habit = Navbase:new(widget)
function Habit:hl_toggle()
  self.highlighted = not self.highlighted
  local box = self.widget.children[1]
  local text = self.widget.children[2]
  if self.highlighted then
    box.check_color = "#bf616a"
    box.bg = "#bf616a"
  else
    box.bg = not box.checked and beautiful.hab_uncheck_bg
    --box.bg = box.checked and beautiful.hab_check_bg or
    --          not box.checked and beautiful.hab_uncheck_bg
    box.check_color = beautiful.hab_check_bg
  end
end

function Habit:hl_off()
end

function Habit:release()
  --self.widget.children[1].checked = true
  self.widget:emit_signal("button::press")
end

-- Return class definitions
return {
  Elevated = Elevated,
  Habit = Habit,
}
