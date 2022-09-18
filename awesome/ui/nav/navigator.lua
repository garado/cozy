
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ █▄█ █▀▄ 

-- I barely understand the algorithm here. Don't ask.
-- Something something depth first traversal through tree.
-- Algos aren't my thing lol

local awful = require("awful")

-- Class definition
local Navigator = {}
function Navigator:new(args)
  args = args or {}

  local o = {}
  o.root        = args.root or nil
  o.curr_area   = nil
  o.keygrabber  = nil
  o.rules       = args.rules or nil
  o.start_area  = nil
  o.start_index = 0
  o.last_key    = ""
  o.shift_active = false

  self.__index = self
  return setmetatable(o, self)
end

-- Toggle selection highlight for the current item.
-- Also toggle for any widgets associated with its parent area (recursive).
function Navigator:select_toggle()
  if self.curr_area then
    self.curr_area:select_toggle_recurse_up()
  end
end

function Navigator:release()
  local item = self:curr_item()
  if item and not item.is_area then
    item:release()
  end
end

-- Helper functions because access syntax is gross
function Navigator:parent()
  if self.curr_area then
    return self.curr_area.parent
  end
end

function Navigator:curr_item()
  if self.curr_area then
    return self.curr_area:get_curr_item()
  end
end

function Navigator:name()
  if self.curr_area then
    return self.curr_area.name
  end
end

-- Set navigator area to a specific area
function Navigator:set_area(target, start_area)
  if target == "root" then
    self.curr_area = self.root
    return
  end

  local area = start_area or self.root
  for i = 1, #area.items do
    if area.items[i].is_area then
      if area.items[i].name == target then
        self.curr_area = area.items[i]
        return
      else
        self:set_area(target, area.items[i])
      end
    end
  end
end

-- Returns true if the target area is a direct neighbor of the
-- starting area, false otherwise
function Navigator:is_direct_neighbor(target)
  -- To check for neighbors there needs to be a parent we can access
  -- If there isn't a parent, assume it's not a neighbor
  local start_area = self.start_area
  if not start_area.parent then return false end

  return start_area.parent:contains(target)
end

-- Returns true if the current area exists, false if it doesn't
-- If it doesn't exist, this finds the nearest suitable area and moves there
-- Needed in case of widgets with dynamic content
function Navigator:check_curr_area_exists()
  if not self.curr_area then return end
  local parent = self:parent()

  if not parent then
    -- If parent doesn't exist, then either we're at root,
    -- or the current area was cut off of the tree
    self.curr_area = self.root
    self.curr_area:select_off_recursive()
    return false
  elseif not parent:contains(self.curr_area) then
    -- If the parent doesn't contain the current area, that means
    -- it was removed at some point. So find the next suitable area
    self.curr_area:select_off_recursive()
    local next_area, new_index = self:find_next_area(self.curr_area, 1)
    if next_area then
      self.curr_area = next_area
      self.index = new_index
    end
    return false
  end

  return true
end

-- Return the next area with a suitable navitem that we can navigate to.
function Navigator:find_next_area(start_area, direction)
  local area = start_area
  start_area.visited = true

  -- determine if navigating left or right
  direction = direction > 0 and 1 or -1
  local left = direction < 0
  local right = direction > 0

  -- set bounds for iteration
  local bounds = 1
  if left then
    bounds = 1
  elseif right then
    bounds = #area.items
  else
    bounds = #area.items
  end

  -- look through area's item table for next navitem to select
  for i = area.index, bounds, direction do
    area.index = i
    local item = area.items[i]

    if item.is_navitem and not item.visited then
      return area, i
    elseif item.is_area and not item.visited then
      -- Increment index only for direct neighbors
      local direct_neighbor = self:is_direct_neighbor(item)

      if right and direct_neighbor then
        item.index = 1
      elseif left and direct_neighbor then
        item.index = #item.items
      end

      return self:find_next_area(item, direction)
    end
  end

  -- If we get here, that means the current area has no suitable  
  -- next navitem anywhere in its item table
  -- So we need to backtrace and look in neighboring areas

  -- But if there is no parent then we can't backtrace, so
  -- force iterate within the current area.
  -- This should only happen with the root area
  if not area.parent then
    self.curr_area = area
    local old_index = self.curr_area.index
    self.curr_area:iter(direction)
    local new_index = self.curr_area.index

    -- if wrapping around the root,
    -- set indices accordingly
    if old_index > new_index then
      self.curr_area:reset_index_recursive()
    else
      if left then
        self.curr_area:max_index_recursive()
      elseif right then
        self.curr_area:reset_index_recursive()
      end
    end

    return self:iter_within_area(direction)
  else
    return self:find_next_area(area.parent, direction)
  end
end

-- Leave the current area and move to a neighboring area
function Navigator:iter_between_areas(val)
  self:check_curr_area_exists()

  -- If parent doesn't exist, then we can't access any neighbors,
  -- so force iterating within the current area
  if not self:parent() then
    return self:iter_within_area(val)
  end

  -- The parent's currently selected item is the current area,
  -- so we need to iterate the parent to make sure it doesnt search the 
  -- current area again
  local start_area = self:parent()
  start_area:iter(val)

  -- Check neighbors
  self.curr_area.visited = true
  local next_area, new_index = self:find_next_area(start_area, val)
  self.curr_area = next_area
  self.curr_area.index = new_index
end

-- Navigate within the current area's items.
-- Returns the area.
function Navigator:iter_within_area(val)
  self:check_curr_area_exists()
  local area = self.curr_area
  local curr_item = self.curr_area:get_curr_item()

  -- If the current item is an area, iterate within that area
  if curr_item.is_area then
    self.curr_area = curr_item
    return self:iter_within_area(0)
  end

  -- If current item is an element, iterate to next element like normal
  if curr_item.is_navitem then
    local next_item = area:iter(val)

    -- If iterating through the current area didn't return anything, 
    -- then you need to check the next area.
    if not next_item then
      curr_item.visited = true
      local new_area, new_index = self:find_next_area(area, val)
      self.curr_area = new_area
      self.curr_area.index = new_index
    else
      return area, area.index
    end
  end
end

-- Functions for handling keypresses
-- Returns rule for a specific key
function Navigator:get_rule(key)
  local box_name = self.curr_area.name
  if self.rules[box_name] and self.rules[box_name][key] then
    return self.rules[box_name][key]
  end
end

-- Execute function for direction keys (hjkl/arrows)
function Navigator:key(key, default)
  self.start_area   = self.curr_area
  self.start_index  = self.curr_area.index
  local area_name = self.curr_area.name
  local rule_exists = self.rules and self.rules[area_name] and self.rules[area_name][key]

  if rule_exists then
    local rule = self:get_rule(key)
    local custom_nav_logic = false
    local amount = rule
    if type(rule) == "function" then
      amount, custom_nav_logic = rule(self.curr_area.index)
    end
    if not custom_nav_logic then
      self:iter_within_area(amount)
    end
  else
    self:iter_within_area(default)
  end
end

function Navigator:backspace()
  self.start_area   = self.curr_area
  self.start_index  = self.curr_area.index
  self:iter_between_areas(-1)
end

function Navigator:tab()
  self.start_area   = self.curr_area
  self.start_index  = self.curr_area.index

  -- Shift+Tab should go backwards.
  local amt = self.shift_active and -1 or 1

  self:iter_between_areas(amt)
end

-- Initialize and start keygrabber
function Navigator:start()
  self.curr_area = self.root.items[1]
  self:select_toggle()

  local function keypressed(_, _, key, _)
    self.root:reset_visited_recursive()
    if key ~= "Return" and key ~= "q"  then self:select_toggle() end

    if     key == "h" or key == "H" then
      self:key("h", -1)
    elseif key == "j" or key == "J" then
      self:key("j", 1)
    elseif key == "k" or key == "K" then
      self:key("k", -1)
    elseif key == "l" or key == "L" then
      self:key("l", 1)
    elseif key == "BackSpace" then
      self:backspace()
    elseif key == "Tab" then
      self:tab()
    elseif key == "Return" then
      self:release()
    elseif key == "Shift_R" or key == "Shift_L" then
      self.shift_active = true
    elseif key == "q" then -- debug: print current hierarchy
      print("\nDUMP: Current pos is "..self.curr_area.name.."("..self.curr_area.index..")")
      self.root:dump()
    end

    if key ~= "Return" and key ~= "q" then self:select_toggle() end
    self.last_key = "key"
  end

  local function keyreleased(_, _, key, _)
    if key == "Shift_R" or key == "Shift_L" then
      self.shift_active = false
    end
  end

  self.keygrabber = awful.keygrabber {
    stop_key = "Mod4",
    stop_event = "press",
    autostart = true,
    keypressed_callback = keypressed,
    keyreleased_callback = keyreleased,
    stop_callback = function()
      self.curr_area = self.root
      self.root:reset()
    end
  }
end

function Navigator:stop()
  self.keygrabber:stop()
end

return Navigator
