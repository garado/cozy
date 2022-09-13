
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

-- Navigate between neighboring boxes.
function Navigate:iter_between(amt)
  print("iter between " .. self.current_box.name)
  -- To get neighbor of current box, access parent.[parent.index + 1]
  -- Make sure there is a neighboring box.
  local parent = self.current_box.parent
  if parent and self.current_box:has_neighbor() then
    local new_box = parent:iter(amt)
    self.current_box = new_box
    self.current_box.index = 1
    local new_current_item = self.current_box:get_current_item()
    if new_current_item.is_box then
      self.current_box:get_current_item():iter(amt)
      self.current_box = new_current_item
    end
    print("Nav: iter_between: New box is " .. self.current_box.name)
    return
  end

  -- If there is no neighbor, backtrace
  self.current_box = parent
  self:iter_between(amt)

end

-- Navigate within a box's items.
function Navigate:iter_within(amt)
  -- Verify that current box still exists.
  -- If it doesn't, go to next box.
  -- (BROKEN! dangling reference)
  local parent = self.current_box.parent
  if parent and not parent:contains(self.current_box) then
    self:iter_between(amt)
  end

  -- If the current item is a box, iterate within that box.
  --local passthrough = self.current_box.passthrough
  local current_item = self.current_box:get_current_item()
  if current_item.is_box then
    self.current_box = current_item
    self:iter_within(amt)
  end

  -- If the current item is an element, iterate to the next element.
  -- Returns the item it iterated to if successful.
  -- Returns nil if unsuccessful, eg if iter amt goes out of item table bounds.
  print("Nav: iter_within within " ..self.current_box.name .. " by " .. amt)
  local ret = self.current_box:iter(amt)
  if ret == nil then
    self:iter_between(amt)
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

-- Override these for custom navigation
function Navigate:h() self:iter_within(-1) end
function Navigate:j() self:iter_within(1)  end
function Navigate:k() self:iter_within(-1) end
function Navigate:l() self:iter_within(1)  end

function Navigate:BackSpace()
  if self.current_box.parent == nil then
    self:iter_within(-1)
  else
    self:iter_between(-1)
  end
end

function Navigate:Tab()
  if self.current_box.parent == nil then
    self:iter_within(1)
  else
    self:iter_between(1)
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
