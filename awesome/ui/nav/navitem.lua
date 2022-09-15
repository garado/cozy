
-- █▄░█ ▄▀█ █░█ █ ▀█▀ █▀▀ █▀▄▀█ 
-- █░▀█ █▀█ ▀▄▀ █ ░█░ ██▄ █░▀░█ 

-- Class definitions for making widgets navigable
-- with the keyboard

local beautiful = require("beautiful")

-- █▄▄ ▄▀█ █▀ █▀▀ 
-- █▄█ █▀█ ▄█ ██▄ 
-- Only responsible for defining basic vars
-- Functions must be overridden in derived classes
local Base = {}
function Base:new(widget)
  local o = {}
  o.widget  = widget -- test
  o.selected    = false
  o.highlighted = false
  setmetatable(o, self)
  self.__index = self
  return o
end

function Base:hl_toggle()  end
function Base:hl_off()     end
function Base:release()    end

-- █▀▀ █░░ █▀▀ █░█ ▄▀█ ▀█▀ █▀▀ █▀▄ 
-- ██▄ █▄▄ ██▄ ▀▄▀ █▀█ ░█░ ██▄ █▄▀ 
local Elevated = Base:new(widget)

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
local Habit = Base:new(widget)

function Habit:hl_toggle()
  self.highlighted = not self.highlighted
  local box = self.widget.children[1]
  if self.highlighted then
    box.check_color = "#bf616a"
    box.bg = "#bf616a"
  else
    box.bg = not box.checked and beautiful.hab_uncheck_bg
    box.check_color = beautiful.hab_check_bg
  end
end

function Habit:hl_off()
  self.highlighted = false
  local box = self.widget.children[1]
  box.bg = not box.checked and beautiful.hab_uncheck_bg
  box.check_color = beautiful.hab_check_bg
end

function Habit:release()
  self.widget:emit_signal("button::press")
end

-- █▀▄ ▄▀█ █▀ █░█    █░█░█ █ █▀▄ █▀▀ █▀▀ ▀█▀ 
-- █▄▀ █▀█ ▄█ █▀█    ▀▄▀▄▀ █ █▄▀ █▄█ ██▄ ░█░ 
local Dashwidget = Base:new(widget)

function Dashwidget:hl_toggle()
  if not self.highlighted then
    self.widget.children[1].bg = beautiful.surface0
  else
    self.widget.children[1].bg = beautiful.dash_widget_bg
  end
  self.highlighted = not self.highlighted
end

function Dashwidget:hl_off() 
  self.highlighted = false
  self.widget.children[1].bg = beautiful.dash_widget_bg
end

function Dashwidget:release()
end

-- █▀▄ ▄▀█ █▀ █░█    ▀█▀ ▄▀█ █▄▄ █▀ 
-- █▄▀ █▀█ ▄█ █▀█    ░█░ █▀█ █▄█ ▄█ 
local Dashtab = Base:new(widget)

function Dashtab:hl_toggle()
  self.highlighted = not self.highlighted
  if self.highlighted then
    self.widget:nav_release()
    self.widget:nav_hl_on()
    self.widget:set_color(beautiful.main_accent)
  else
    self.widget:nav_hl_off()
    self.widget:set_color(beautiful.dash_tab_fg)
  end
end

function Dashtab:hl_off()
  self.highlighted = false
  self.widget:nav_hl_off()
end

function Dashtab:release()
  self.widget:nav_release()
end

-- Return class definitions
return {
  Elevated = Elevated,
  Habit = Habit,
  Dashtab = Dashtab,
  Dashwidget = Dashwidget,
}
