
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀▀ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ ██▄ 

local awful = require("awful")
local gobject = require("gears.object")

local Navigate = {}
function Navigate:new(tree)
  local o = gobject{}
  o.tree = tree or nil
  o.current_box = nil
  o.keygrabber = nil
  o:connect_signal("nav::update_tree", function(new_tree)
    o.tree = new_tree
  end)
  self.__index = self
  return setmetatable(o, self)
end

function Navigate:outer_iter(amt)
  local parent = self.current_box.parent
  local new_box = parent:iter(amt)
  self.current_box = new_box
  self.current_box.index = 1
  print("Nav: iterated. New box is " .. self.current_box.name)
end

function Navigate:inner_iter(amt)
  local parent = self.current_box.parent
  if not parent:contains(self.current_box) then
    self:outer_iter(amt)
  end
  print("Nav: iterating within " ..self.current_box.name .. "'s items by " .. amt)
  local ret = self.current_box:iter(amt)
  if ret == nil then
    self:outer_iter(amt)
    if amt > 0 then
      self.current_box:set_index(1)
    else
      self.current_box:set_index(#self.current_box.items)
    end
  end
end

function Navigate:hl_toggle()
  local item = self.current_box:get_current_item()
  if item and not item.is_box then
    item:hl_toggle()
  end
end

function Navigate:hl_off()
  local item = self.current_box:get_current_item()
  if item and not item.is_box then
    item:hl_off()
  end
end

function Navigate:release()
  local item = self.current_box:get_current_item()
  if item and not item.is_box then
    item:release()
  end
end

-- Override these!
function Navigate:h() self:inner_iter(-1) end
function Navigate:j() self:inner_iter(1)  end
function Navigate:k() self:inner_iter(-1) end
function Navigate:l() self:inner_iter(1)  end

function Navigate:BackSpace()
  if self.current_box.name == "root" then
    self:inner_iter(-1)
  else
    self:outer_iter(-1)
  end
end

function Navigate:Tab()
  if self.current_box.name == "root" then
    self:inner_iter(1)
  else
    self:outer_iter(1)
  end
end

function Navigate:start(root)
  print("Navigate: starting navigation on " .. root.name)
  self.tree = root
  self.current_box = root.items[1]
  self:hl_toggle()
  print("The current box is " .. self.current_box.name)

  local function keypressed(_, _, key, _)
    if key ~= "Return"  then self:hl_toggle() end

    if     key == "h" then
      self:h()
    elseif key == "j" then
      self:j()
    elseif key == "k" then
      self:k()
    elseif key == "l" then
      self:l()
    elseif key == "BackSpace" then
      self:BackSpace()
    elseif key == "Tab" then
      self:Tab()
    elseif key == "Return" then
      self:release()
    elseif key == "q" then -- debug
      print("\nDUMP: Current pos is "..self.current_box.name.."("..self.current_box.index..")")
      self.tree:dump()
    end

    if key ~= "Return" then self:hl_toggle() end
  end

  self.keygrabber = awful.keygrabber {
    stop_key = "Mod4",
    stop_event = "press",
    autostart = true,
    keypressed_callback = keypressed,
    stop_callback = function()
      self:hl_off()
      self.current_box = self.tree
    end
  }
end

function Navigate:stop()
  self.keygrabber:stop()
end

return Navigate
