
-- ▄▀█ █▀█ █▀▀ ▄▀█ 
-- █▀█ █▀▄ ██▄ █▀█ 

-- Basic unit for the nav hierarchy. Can contain navitems or child areas.

local Area = {}
function Area:new(args)
  local o = {}
  o.name      = args.name or "unnamed"
  o.parent    = args.parent or nil
  o.items     = args.items or {}
  o.widget    = args.widget or nil
  o.index     = 1
  o.is_area   = true
  o.is_navitem = false
  o.visited   = false
  o.circular  = args.circular or false
  self.__index = self
  return setmetatable(o, self)
end

-- Override equality operator to check if 2 boxes are equal.
function Area:__eq(b)
  return self.name == b.name
end

-- Append item to area's item table.
function Area:append(item)
  if item.is_area then
    item.parent = self
  end
  table.insert(self.items, item)
end

-- Actions for area's attached widget
function Area:release() end
function Area:select_toggle()
  if self.widget then
    self.widget:select_toggle()
  end
end

-- Useful for if you have nested areas.
function Area:select_toggle_recurse_up()
  if self.widget then
    self.widget:select_toggle()
  end
  if self.parent then
    self.parent:select_toggle_recurse_up()
  end
end

-- Turn off highlight for associated widget
function Area:select_off()
  if self.widget then
    self.widget:select_off()
  end
end

-- Turn off highlight for all child items
function Area:select_off_recursive()
  if self.widget then
    self.widget:select_off()
  end
  for i = 1, #self.items do
    if self.items[i].is_area then
      self.items[i]:select_off_recursive()
    else
      self.items[i]:select_off()
      if self.items[i].selected then
      end
    end
  end
end

-- Remove an item from a given index in the item table.
function Area:remove_index(index)
  local item = self.items[index]
  if item then
    -- Turn off highlight
    if item.is_area then
      item:select_off_recursive()
    else
      item:select_off()
    end
    table.remove(self.items, index)
  end
end

-- Remove a specific area from area's item table.
function Area:remove_item(item)
  item:select_off_recursive()
  if self.items[self.index] == item then
    self.index = 1
  end
  for i = 1, #self.items do
    if item == self.items[i] then
      table.remove(self.items, i)
      self.index = self.index - 1
      if self.index < 0 then self.index = 1 end
      return
    end
  end
end

-- Returns if current area contains a given area.
function Area:contains(item)
  if not item.is_area then return end
  for i = 1, #self.items do
    if self.items[i].is_area then
      if self.items[i] == item then
        return true
      end
    end
  end
  return false
end

function Area:set_index(index)
end

-- Iterate through an area's item table by a given amount.
-- Returns the item that it iterated to.
function Area:iter(amount)
  local new_index = self.index + amount

  -- If iterating went out of item table's bounds and the area isn't
  -- circular, then return nil.
  local overflow = new_index > #self.items or new_index <= 0
  if not self.circular and overflow then
    print("overflow!")
    return
  end

  -- Otherwise, iterate like normal.
  self.index = new_index % #self.items
  if self.index == 0 then
    self.index = #self.items
  end
  return self.items[self.index]
end

function Area:iter_without_set(amount)
  local new_index = self.index + amount

  -- If iterating went out of item table's bounds and the area isn't
  -- circular, then return nil.
  local overflow = new_index > #self.items or new_index < 0
  if not self.circular and overflow then
    return
  end

  -- Otherwise, iterate like normal.
  new_index = new_index % #self.items
  if new_index == 0 then new_index = #self.items end
  return self.items[new_index]
end

-- Remove all child items except for the given area
-- Returns true if successful, false otherwise
function Area:remove_all_except_item(item)
  -- Item must be an area
  if item and not item.is_area then
    return false
  end

  -- Must contain item to begin with
  if not self:contains(item) then
    return false
  end

  -- Execute
  for i = 1, #self.items do
    local curr = self.items[i]
    if curr.is_area and not (curr == item) then
      table.remove(self.items, i)
      if i < self.index then
        self.index = self.index - 1
        if self.index < 0 then self.index = 1 end
      end
    end
  end

  return #self.items == 1 and self.items[1] == item
end

-- Reset area to defaults.
-- Deselect any children and set the index back to 1.
function Area:reset()
  self:select_off_recursive()
  self:reset_visited_recursive()
  self:reset_index_recursive()
  self.index = 1
end

function Area:max_index_recursive()
  self.index = #self.items
  for i = 1, #self.items do
    if self.items[i].is_area then
      self.items[i]:max_index_recursive()
    end
  end
end

function Area:reset_index_recursive()
  self.index = 1
  for i = 1, #self.items do
    if self.items[i].is_area then
      self.items[i]:reset_index_recursive()
    end
  end
end

-- Remove all items from area.
function Area:remove_all_items()
  for i = 1, #self.items do
    table.remove(self.items, i)
  end

  self.index = 1
end

-- Return the currently selected item within the item table.
function Area:get_curr_item()
  return self.items[self.index]
end

function Area:is_empty() return #self.items == 0 end

-- Sets visited = false for area and all child areas
function Area:reset_visited_recursive()
  self.visited = false
  for i = 1, #self.items do
    if self.items[i].is_area then
      self.items[i]:reset_visited_recursive()
    elseif self.items[i].is_navitem then
      self.items[i].visited = false
    end
  end
end

-- Print area contents.
function Area:dump(space)
  space = space or ""
  print(space.."'"..self.name.."["..tostring(self.index).."]': "..#self.items.." items")
  space = space .. "  "
  for i = 1, #self.items do
    if self.items[i].is_area then
      self.items[i]:dump(space .. "  ")
    end
  end
end

return Area

