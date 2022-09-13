
-- █▄░█ ▄▀█ █░█ █▀▀ █░░ ▄▀█ █▀ █▀ █▀▀ █▀ 
-- █░▀█ █▀█ ▀▄▀ █▄▄ █▄▄ █▀█ ▄█ ▄█ ██▄ ▄█ 

-- Class definitions for making widgets navigable
-- with the keyboard

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

-- Return class definitions
return {
  Elevated = Elevated,
}
