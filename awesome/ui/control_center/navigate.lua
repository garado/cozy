
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀▀ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ ██▄ 

-- Custom navigation for control center

local Navigate = require("ui.nav.navigate")

local nav = Navigate:new()

function nav:j()
  local name = self.current_box.name
  local index = self.current_box.index
  if name == "qactions" then
    if index > 5 then
      self:iter_between(1)
    else
      self:iter_within(5)
    end
  elseif name == "links" then
    if index > 4 then
      self:iter_between(1)
    else
      self:iter_within(2)
    end
  elseif name == "power_opts" then
    self:iter_between(1)
  elseif name == "power_confirm" then
    self:iter_between(1)
  end
end

function nav:k()
  local name = self.current_box.name
  local index = self.current_box.index
  if name == "qactions" then
    if index < 5 then
      self:iter_between(-1)
      self.current_box.index = #self.current_box.items
    else
      self:iter_within(-5)
    end
  elseif name == "links" then
    if index < 3 then
      self:iter_between(-1)
    else
      self:iter_within(-2)
    end
  elseif name == "power_opts" then
    self:iter_between(-1)
    self.current_box.index = #self.current_box.items
  elseif name == "power_confirm" then
    self:iter_between(-1)
  end
end

return nav
