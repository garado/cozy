
-- █▄▄ █▀█ ▀▄▀ 
-- █▄█ █▄█ █░█ 

-- A box has a name and a table of items.
-- Each keypress navigates through a box's items.
-- The box remembers your position in its item table 
-- when you iterate through it using its index field.

-- A box can be circular (iterating through it wraps around),
-- or linears (returns nil when you iterate through the whole thing).

-- A box also remembers its parent.

local Box = { }
function Box:new(args)
  local o = {}
  o.name  = args.name or "unnamed"
  print("Creating new Box called " .. o.name)
  o.parent = args.parent or nil
  o.items  = args.items or {}
  o.index  = 1
  o.is_box = true
  o.circular = args.circular or false
  self.__index = self
  return setmetatable(o, self)
end

function Box:__eq(b)
  return self.name == b.name
end

-- Append item to box's item table.
function Box:append(item)
  print("Box: appending to "..self.name)
  table.insert(self.items, item)
end

-- Turn off highlight for all children
function Box:hl_off_recursive()
  for i = 1, #self.items do
    if self.items[i].is_box then
      self.items[i]:hl_off_recursive()
    else
      self.items[i]:hl_off()
    end
  end
end

-- Remove item from box's item table.
function Box:remove_item(item)
  print("Removing "..item.name)
  item:hl_off_recursive()
  if self.items[self.index] == item then
    print("Removing currently indexed item! Adjusting...")
    self:iter(1)
  end
  for i = 1, #self.items do
    if item == self.items[i] then
      table.remove(self.items, i)
    end
  end
end

-- Returns if current box contains a given box.
function Box:contains(box)
  for i = 1, #self.items do
    if self.items[i].is_box then
      if self.items[i] == box then
        return true
      end
    end
  end
  return false
end

-- Returns if the current Box has a neighbor.
function Box:has_neighbor()
  if self.name == "root" then
    return false
  end
  return #self.parent.items > 1
end

-- Iterate through a box's elements by a given amount.
-- Returns the item you iterated to.
function Box:iter(amount)
  print("Box: iterating through "..self.name)
  local new_index = self.index + amount

  -- Next element
  local overflow = new_index > #self.items or new_index == 0
  if not self.circular and overflow and self:has_neighbor() then
    print("Box: item table overflow in "..self.name)
    print("Must call outer_iter in parent")
    return nil
  end

  self.index = new_index % #self.items
  if self.index == 0 then self.index = #self.items end
  --print("Box: " .. self.name .. " iterated. New elem is " .. self.index)
  print("New index is " .. self.index)
  return self.items[self.index]
end

function Box:set_index(index)
  self.index = index
end

function Box:reset_index()
  self.index = #self.items > 0 and 1 or 0
end

function Box:clear_items()
  for i = 1, #self.items do
    table.remove(self.items, i)
  end
end

function Box:get_current_item()
  return self.items[self.index]
end

function Box:release() end
function Box:hl_toggle() end
function Box:hl_off() end

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

