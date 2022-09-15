
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀▀ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ ██▄ 

local awful = require("awful")
local gobject = require("gears.object")

local Navigate = {}
function Navigate:new(root)
  local o = gobject{}
  o.root = root or nil
  o.current_box = nil
  o.keygrabber = nil
  o.rules = {}
  o:connect_signal("nav::update_root", function(new_root)
    o.root = new_root
  end)
  self.__index = self
  return setmetatable(o, self)
end

function Navigate:get_index()
  if self.current_box then
    return self.current_box.index
  else
    return 0
  end
end

-- Navigate to a box's neighbors.
function Navigate:iter_between(amt)
  -- If the current box doesn't exist (eg it was removed),
  -- you can't iterate within it.
  -- So go to the next box.
  -- (BROKEN! dangling reference)
  local parent = self.current_box.parent
  if parent and not parent:contains(self.current_box) then
    --print("Uh oh I don't exist anymore")
    self.current_box = parent
    self:iter_within(parent)
    --self:iter_between(amt)
  end

  if self.current_box.iter_between_hl_persist then
    self.current_box:get_current_item():hl_toggle()
  end
  --print("Nav: iter_between: current box is "..self.current_box.name)

  -- If there is an associated widget, toggle highlight
  if self.current_box.widget then
    if not self.current_box.iter_between_hl_persist then
      self.current_box.widget:hl_toggle()
    end
  end

  -- If there is no parent, you are at the root of the tree,
  -- so there are no neighbors to iterate to.
  -- So just iterate within the root box. 
  if not self.current_box.parent then
    --print("Nav: iter between has no parent for "..self.current_box.name)
    --print("   Calling iter_within")
    self:iter_within(amt)
    --print("   Finished called iter_within")
    return
  end

  -- To get neighbor of current box, access parent.[parent.index + 1]

  --print("Nav: iterating between " .. self.current_box.name)
  -- First make sure there is a neighboring box.
  local parent = self.current_box.parent
  if parent and self.current_box:has_neighbor() then
    --print("   Parent exists and there is a neighbor!")
    local neighbor = parent:iter(amt)

    -- ???
    if neighbor and neighbor.is_box and neighbor:is_empty() then
      self.current_box = neighbor
      self:iter_between(amt)
    end

    self.current_box = neighbor
    self.current_box.index = 1
    local new_current_item = self.current_box:get_current_item()
    if new_current_item.is_box then
      --print("Iterated to box "..new_current_item.name.."; iterating within that box")
      self.current_box = new_current_item
      if self.current_box.widget then
        self.current_box.widget:hl_toggle()
      end
      self:iter_within(0)
    end
    --print("New box is " .. self.current_box.name)
    return
  end

  -- If there is no neighbor and the parent is root, DON'T backtrace.
  -- Just iterate within.
  if parent.parent == nil then
    --print("   There is no neighbor and the parent is root.")
    --print("   Calling iter_within on self ("..self.current_box.name..")")
    self:iter_within(amt)
    return
  end

  -- If there is no neighbor, backtrace
  self.current_box = parent
  if amt > 0 then amt = 1 else amt = -1 end
  self:iter_between(amt) -- usually +1 or -1
  if self.current_box.widget then
    self.current_box.widget:hl_toggle()
  end
end

-- Navigate within a box's items.
function Navigate:iter_within(amt)
  -- If the current box doesn't exist (eg it was removed),
  -- you can't iterate within it.
  -- So go to the next box.
  -- (BROKEN! dangling reference)
  local parent = self.current_box.parent
  --print("Checking if "..self.current_box.name.. " exists")
  if not parent then
    --print("Uh oh I don't exist anymore and my parent is dead. Setting new box to root")
    self.current_box = self.root
    --print("Okayyy new box is called "..self.current_box.name.." and its index is "..self.current_box.index)
    self.index = 1
  elseif parent and not parent:contains(self.current_box) then
    --print("Uh oh I don't exist anymore")
    self.current_box = parent
    self:iter_within(parent)
  end

  -- If the current item is a box, iterate within that box.
  local current_item = self.current_box:get_current_item()
  if current_item.is_box then
    --print("The current item is a box called "..current_item.name.." and its index is "..current_item.index)
    if current_item.widget then
      current_item.widget:hl_toggle()
    end
    self.current_box = current_item
    self:iter_within(amt)
    return
  end

  -- If the current item is an element, iterate to the next element.
  -- Returns the item it iterated to if successful.
  -- Returns nil if unsuccessful, eg if iter amt goes out of item table bounds.
  --print("Nav: iter_within within " ..self.current_box.name .. " by " .. amt)
  local ret = self.current_box:iter(amt)
  if ret == nil then
    --print("iter_within on "..self.current_box.name.."returned nil")
    --print("iterating between")
    if amt > 0 then amt = 1 else amt = -1 end
    self:iter_between(amt)
    if amt > 0 then
      self.current_box.index = 1
    else
      self.current_box.index = #self.current_box.items
    end
  end
end

function Navigate:hl_toggle()
  local item = self.current_box:get_current_item()
  if item and not item.is_box and not self.current_box.iter_between_hl_persist then
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

function Navigate:set_rules(rules)
  self.rules = rules
end

-- returns rule
function Navigate:get_rule(key)
  local box_name = self.current_box.name
  if self.rules[box_name] and self.rules[box_name][key] then
    return self.rules[box_name][key]
  else
  end
end

function Navigate:key(key, default)
  local box_name = self.current_box.name
  if self.rules[box_name] and self.rules[box_name][key] then
    self:iter_within(self:get_rule(key))
  else
    self:iter_within(default)
  end
end

--function Navigate:h()
--  local box_name = self.current_box.name
--  if self.rules[box_name] and self.rules[box_name].h then
--    self:iter_within(self:get_rule("h"))
--  else
--    self:iter_within(-1)
--  end
--end
--
--function Navigate:j()
--  local box_name = self.current_box.name
--  if self.rules[box_name] and self.rules[box_name].j then
--    self:iter_within(self:get_rule("j"))
--  else
--    self:iter_within(1)
--  end
--end
--
--function Navigate:k()
--  local box_name = self.current_box.name
--  if self.rules[box_name] and self.rules[box_name].k then
--    self:iter_within(self:get_rule("k"))
--  else
--    self:iter_within(-1)
--  end
--end
--
--function Navigate:l()
--  local box_name = self.current_box.name
--  if self.rules[box_name] and self.rules[box_name].l then
--    self:iter_within(self:get_rule("l"))
--  else
--    self:iter_within(1)
--  end
--end

-- Rules specify how to iterate through a box's items.
function Navigate:set_rules(rules)
  self.rules = rules
end

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
  --print("Navigate: starting navigation on " .. root.name)
  self.root = root
  self.current_box = root.items[1]
  self:hl_toggle()
  --print("The current box is " .. self.current_box.name)

  local function keypressed(_, _, key, _)
    if key ~= "Return"  then self:hl_toggle() end

    if     key == "h" or key == "H" then
      self:key("h", -1)
      --self:h()
    elseif key == "j" or key == "J" then
      self:key("j", 1)
      --self:j()
    elseif key == "k" or key == "K" then
      self:key("k", -1)
      --self:k()
    elseif key == "l" or key == "L" then
      self:key("l", 1)
      --self:l()
    elseif key == "BackSpace" then
      self:BackSpace()
    elseif key == "Tab" then
      --print("====== TAB PRESSED ======")
      self:Tab()
    elseif key == "Return" then
      self:release()
    elseif key == "q" then -- debug
      print("\nDUMP: Current pos is "..self.current_box.name.."("..self.current_box.index..")")
      self.root:dump()
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
      self.current_box = self.root
    end
  }
end

function Navigate:stop()
  self.keygrabber:stop()
end

return Navigate
