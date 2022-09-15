
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ █▄█ █▀▄ 

local awful = require("awful")

-- For debugging.
SPACES = ""
function set_spaces()
  SPACES = SPACES .. "  "
end
function remove_spaces()
  SPACES = string.gsub(SPACES, "^  ", "")
end

-- Outside helper functions
local function to_ones(amt)
  if amt > 0 then return 1 else return -1 end
end

local Navigator = {}
function Navigator:new(args)
  args = args or {}

  local o = {}
  o.root        = args.root or nil
  o.curr_area    = nil
  o.keygrabber  = nil
  o.rules       = args.rules or nil
  self.__index = self
  return setmetatable(o, self)
end

-- Inside helper functions
-- To help with unwieldy syntax
function Navigator:parent()
  if self.curr_area then
    return self.curr_area.parent
  end
end

-- Returns rule for a specific key
function Navigator:get_rule(key)
  local box_name = self.curr_area.name
  if self.rules[box_name] and self.rules[box_name][key] then
    return self.rules[box_name][key]
  end
end

-------------------------

-- find the next fucking area
function Navigator:find_next_area_within(direction, area)
  local bounds = #area.items
  if direction < 0 then bounds = 0 end
  set_spaces()
  print(SPACES.."::Nav:find_next_area_within is searching area "..area.name.." starting at index "..area.index)
  set_spaces()
  for i = area.index, bounds, direction do
    if area.items[i].is_area then
      print(SPACES.."Currently selected item is an area")
      remove_spaces()
      return self:find_next_area_within(direction, area.items[i])
    else
      print(SPACES.."Currently selected item is not an area!")
      print(SPACES.."Neighbor found: "..area.name..", and its index is "..tostring(i))
      remove_spaces()
      return area
    end
  end
  remove_spaces()
end

-- Find neighbor.
-- Return the area that the neighbor is in.
function Navigator:get_neighbor(direction, area)
  set_spaces()
  print(SPACES.."::Navigator:get_neighbor-ing area for item number "..area.index.." in ".. area.name)

  if area.parent == nil then
    print(SPACES.."Cannot find neighbor because parent does not exist")
    remove_spaces()
    return false
  end

  -- If parent is circular then as long as parent has more than 1 item
  -- there is always a neighbor
  if area.parent.circular then
    print(SPACES.."Parent ("..area.parent.name..") is circular: checking for neighbor element within parent")
    local neighboring_item = area.parent:iter(direction)
    if neighboring_item.is_navitem then
      print(SPACES.."Found a neighbor for element within "..area.name.." its neighbor is an element within "..area.name)
      remove_spaces()
      return area.parent
    elseif neighboring_item.is_area then
      print(SPACES.."Neighboring element is an area called "..neighboring_item.name..", checking if it currently selects an area")
      if neighboring_item:get_curr_item().is_area then
        print(SPACES.."It currently selects an area, checking next element within it for an area...")
        --for i = 1, #neighboring_item.items do
        --end
        return self:find_next_area_within(direction, neighboring_item)
        --return self:get_neighbor(direction, neighboring_item)
      else
        return neighboring_item
      end
    end
  else
    print(SPACES.."Parent ("..area.parent.name..") is not circular")
    local left = direction < 0
    local right = direction > 0

    if left then
      print(SPACES.."Checking for an area to the left of "..area.name)

      if area.parent.index == 1 then
        remove_spaces()
        return self:get_neighbor(direction, area.parent)
      end

      remove_spaces()
      return
    end

    if right then
      print(SPACES.."Checking for an area to the right of "..area.name)
      remove_spaces()
      return
    end
  end
end

-------------------------

-- Before iterating through a box, we need to make sure it wasn't
-- removed.
function Navigator:check_curr_area_exists(amount)
  local parent = self:parent()
  if not parent then
    set_spaces()
    print(SPACES.."Navigator:check_curr_area_exists: "..self.name.." no longer exists! Resetting to root")
    remove_spaces()
    -- If parent doesn't exist, reset to root.
    self.curr_area = self.root
    self.curr_idx = 1
  elseif not parent:contains(self.curr_area) then
    set_spaces()
    print(SPACES.."Navigator:check_curr_area_exists: "..self.name.." no longer exists! Trying to find next existing neighbor")
    -- If the parent doesn't contain the current box,
    -- then iterate to its next existing neighbor.
    self.curr_area = parent
    self:iter_within(to_ones(amount))
    remove_spaces()
  end
end

-- Navigate within a box's items.
function Navigator:iter_within(amt)
  print(SPACES.."**Root index: "..tostring(self.root.index))
  print(SPACES.."::Navigator:iter_within "..self.curr_area.name)
  set_spaces()
  self:check_curr_area_exists(amt)

  -- If the current item is a box, iterate within that box
  local curr_item = self.curr_area:get_curr_item()
  if curr_item.is_area then
    print(SPACES.."The current item is a box called "..self.curr_area:get_curr_item().name)
    -- If the box has a widget associated with it, toggle hl
    if curr_item.widget then
      print(SPACES.."Current item is a box with an associated widget")
      curr_item.widget:select_toggle()
    end

    print(SPACES.."The currently selected item within the area "..self.curr_area.name.." is another area itself (called "..self.curr_area:get_curr_item().name.."). Recursing...")

    self.curr_area = curr_item
    self:iter_within(0)
    --self:iter_within(to_ones(amt))
    return
  end

  -- If the current item is an element, iterate to the next element.
  local ret = self.curr_area:iter(amt)
  if ret then
    print("Next element successfully found.")
    return
  end
  if ret == nil then
    -- If iterating through item table went out of bounds,
    -- then look to the neighboring box for the next element.
    local neighbor = self.get_neighbor(amt, self.curr_area)
    if not neighbor then
      -- If it doesn't have a neighbor then do nothing I guess
    else
      print(SPACES.."The neighboring area is "..neighbor.name)
    end

    --if self.curr_area:has_neighbor() then
    --  self:iter_between(to_ones(amt))
    --  if amt > 0 then
    --    self.curr_area.index = 1
    --  else
    --    self.curr_area.index = #self.curr_area.items
    --  end
    --else
    --  -- If it doesn't have a neighbor idk what to do
    --  -- Nothing I guess
    --end
  end
  remove_spaces()
end

-- Navigate to a box's neighbors.
function Navigator:iter_between(amt)
  set_spaces()
  print(SPACES.."**Root index: "..tostring(self.root.index))
  print(SPACES.."::Navigator:iter_between "..self.curr_area.name)
  self:check_curr_area_exists(amt)

  -- If there is an associated widget, toggle its highlight
  if self.curr_area.widget then
    print(SPACES.."Current item is a box with an associated widget")
    if not self.curr_area.iter_between_hl_persist then
      self.curr_area.widget:select_toggle()
    end
  end

  -- If there is no parent, you are at the root of the nav hierarchy,
  -- so there are no neighbors to iterate to. 
  -- So iterate within the root box.
  if not self.curr_area.parent then
    print(SPACES.."You are at the root. Must iterate within root's children.")
    self:iter_within(amt)
    remove_spaces()
    return
  end

  print(SPACES.."**Root index: "..tostring(self.root.index))
  print("NEIGHBOR")
  local neighbor = self:get_neighbor(to_ones(amt), self.curr_area)
  print(SPACES.."**Root index: "..tostring(self.root.index))

  if neighbor then
    self.curr_area = neighbor
    print(SPACES.."The neighboring area is "..neighbor.name)
  else
  print(SPACES.."**Root index: "..tostring(self.root.index))
    -- If there's no neighbor and we're not at root then we 
    -- can't do anything.
  end

  remove_spaces()
end

-- Action functions for.curr_area's associated widget
function Navigator:select_toggle()
  local item = self.curr_area:get_curr_item()
  if item and not item.is_area and not self.curr_area.iter_between_hl_persist then
    item:select_toggle()
  end
end

function Navigator:select_off()
  local item = self.curr_area:get_curr_item()
  if item and not item.is_area then
    item:select_off()
  end
end

function Navigator:release()
  local item = self.curr_area:get_curr_item()
  if item and not item.is_area then
    item:release()
  end
end

function Navigator:key(key, default)
  local box_name = self.curr_area.name
  if self.rules[box_name] and self.rules[box_name][key] then
    self:iter_within(self:get_rule(key))
  else
    self:iter_within(default)
  end
end

--function Navigator:h()
--  local box_name = self.curr_area.name
--  if self.rules[box_name] and self.rules[box_name].h then
--    self:iter_within(self:get_rule("h"))
--  else
--    self:iter_within(-1)
--  end
--end
--
--function Navigator:j()
--  local box_name = self.curr_area.name
--  if self.rules[box_name] and self.rules[box_name].j then
--    self:iter_within(self:get_rule("j"))
--  else
--    self:iter_within(1)
--  end
--end
--
--function Navigator:k()
--  local box_name = self.curr_area.name
--  if self.rules[box_name] and self.rules[box_name].k then
--    self:iter_within(self:get_rule("k"))
--  else
--    self:iter_within(-1)
--  end
--end
--
--function Navigator:l()
--  local box_name = self.curr_area.name
--  if self.rules[box_name] and self.rules[box_name].l then
--    self:iter_within(self:get_rule("l"))
--  else
--    self:iter_within(1)
--  end
--end

-- Rules specify how to iterate through a box's items.
function Navigator:set_rules(rules)
  self.rules = rules
end

function Navigator:BackSpace()
  if self.curr_area.parent == nil then
    self:iter_within(-1)
  else
    self:iter_between(-1)
  end
end

function Navigator:Tab()
  if self.curr_area.parent == nil then
    self:iter_within(1)
  else
    self:iter_between(1)
  end
end

function Navigator:start(root)
  self.root = root
  self.curr_area = root.items[1]
  self:select_toggle()

  local function keypressed(_, _, key, _)
    print("\n=== KEYPRESS ===")
    SPACES = ""
    if key ~= "Return" and key ~= "q"  then self:select_toggle() end

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
      self:Tab()
    elseif key == "Return" then
      self:release()
    elseif key == "q" then -- debug
      print("\nDUMP: Current pos is "..self.curr_area.name.."("..self.curr_area.index..")")
      self.root:dump()
    end

    if key ~= "Return" and key ~= "q" then self:select_toggle() end
  end

  self.keygrabber = awful.keygrabber {
    stop_key = "Mod4",
    stop_event = "press",
    autostart = true,
    keypressed_callback = keypressed,
    stop_callback = function()
      self:select_off()
      self.curr_area = self.root
    end
  }
end

function Navigator:stop()
  self.keygrabber:stop()
end

return Navigator
