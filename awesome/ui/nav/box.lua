
-- █▄▄ █▀█ ▀▄▀ 
-- █▄█ █▄█ █░█ 

-- A box has a name and a table of items.
-- Each keypress navigates through a box's items.
-- The box remembers your position in its item table 
-- when you iterate through it using its index field.

-- A box can be circular (iterating through it wraps around),
-- or linear (returns nil when you iterate through the whole thing).

-- A box also remembers its parent.

local Box = { }
function Box:new(args)
  local o = {}
  o.name  = args.name or "unnamed"
  --print("Creating new Box called " .. o.name)
  o.parent = args.parent or nil
  o.items  = args.items or {}
  o.widget = args.widget or nil
  o.index  = 1
  o.is_box = true
  o.circular = args.circular or false
  self.__index = self
  return setmetatable(o, self)
end

-- Override equality operator, to check if 2 boxes are equal.
function Box:__eq(b)
  return self.name == b.name
end

-- Append item to box's item table.
function Box:append(item)
  if item.is_box then
    --print("appending " .. item.name .. " to " .. self.name)
    item.parent = self
  end
  table.insert(self.items, item)
end

-- Actions for box's attached widget
function Box:release() end
function Box:hl_toggle()
  if self.widget then
    self.widget:hl_toggle()
  end
end

-- Turn off highlight for associated widget
function Box:hl_off()
  if self.widget then
    self.widget:hl_off()
  end
end

-- Turn off highlight for all child items
function Box:hl_off_recursive()
  if self.widget then
    self.widget:hl_off()
  end
  for i = 1, #self.items do
    if self.items[i].is_box then
      self.items[i]:hl_off_recursive()
    else
      self.items[i]:hl_off()
    end
  end
end

function Box:remove_index(index)
  local item = self.items[index]
  if item then
    -- Turn off highlight
    if item.is_box then
      item:hl_off_recursive()
    else
      item:hl_off()
    end
    table.remove(self.items, index)
  end
end

-- Remove item from box's item table.
function Box:remove_item(item)
  if item.is_box then
    item.parent = nil
  end
  item:hl_off_recursive()
  if self.items[self.index] == item then
    self.index = 1
  end
  for i = 1, #self.items do
    if item == self.items[i] then
      table.remove(self.items, i)
    end
  end
end

-- Returns if current box contains a given box.
function Box:contains(item)
  if not item.is_box then return end
  --print("Box: checking if "..self.name.." contains a box "..item.name)
  for i = 1, #self.items do
    if self.items[i].is_box then
      --print("   Checking if "..self.items[i].name.." is equal to me.")
      if self.items[i] == item then
        return true
      end
    end
  end
  return false
end

-- Returns if the current Box has a neighbor.
function Box:has_neighbor()
  if self.name == "root" then return false end
  if self.parent == nil then return false end
  return #self.parent.items > 1
end

-- Iterate through a box's elements by a given amount.
-- Returns the element you iterated to.
function Box:iter(amount)
  --print("Box: iterating through "..self.name.." by "..amount)

  local new_index = self.index + amount

  -- Go to neighbor
  local overflow = new_index > #self.items or new_index < 0
  if not self.circular and overflow and self:has_neighbor() then
    --print("Box: item table overflow in "..self.name.."; must call outer_iter in parent")
    return
  end

  -- Iterate like normal
  self.index = new_index % #self.items
  if self.index == 0 then self.index = #self.items end
  --print("Box: " .. self.name .. " iterated. New elem is " .. self.index)
  ----print("New index is " .. self.index)
  return self.items[self.index]
end

-- Remove all child items that aren't the given box
function Box:remove_all_except_item(item)
  -- Item must be a box
  if item and not item.is_box then return end
  for i = 1, #self.items do
    local curr = self.items[i]
    if curr.is_box and not curr == item then
      table.remove(self.items, curr)
    end
  end
end

function Box:reset()
  self:hl_off_recursive()
  self.index = 1
end

function Box:clear_items()
  for i = 1, #self.items do
    table.remove(self.items, i)
  end
  self.index = self.index + 1
  if self.index > #self.items then
    self.index = 1
  end
end

function Box:get_current_item()
  return self.items[self.index]
end

function Box:is_empty() return #self.items == 0 end

function Box:dump(space)
  space = space or ""
  print(space.."'"..self.name.."': "..#self.items.." items")
  space = space .. "  "
  for i = 1, #self.items do
    if self.items[i].is_box then
      self.items[i]:dump(space .. "  ")
    end
  end
end

return Box

