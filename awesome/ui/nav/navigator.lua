
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ █▄█ █▀▄ 

local awful = require("awful")
local gobject = require("gears.object")
local area = require("ui.nav.area")

-- For printing stacktrace
local debug_mode = false
local spaces = ""
local function set_spaces()
  spaces = spaces .. "  "
end
local function remove_spaces()
  spaces = string.gsub(spaces, "^  ", "")
end
local function navprint(msg)
  if debug_mode then print(spaces..msg) end
end

---

-- Class definition
local Navigator = {}
function Navigator:new(args)
  args = args or {}

  local o = gobject{}
  o.root  = area:new({
    name = "root",
    circular = true,
    nav = o,
  })
  o.curr_area   = nil
  o.keygrabber  = nil
  o.rules       = args.rules or nil
  o.start_area  = nil
  o.start_index = 0
  o.last_key    = ""
  o.last_area   = ""
  o.shift_active = false

  o:connect_signal("nav::area_removed", function(navigator, parent, removed_area)
    self:handle_removed_area(navigator, parent, removed_area)
  end)

  self.__index = self
  return setmetatable(o, self), o.root
end

-- Action functions

-- Toggle selection highlight for the current item.
-- Also toggle for any widgets associated with its parent area (recursive).
function Navigator:select_toggle()
  self.curr_area:select_toggle_recurse_up()
end

function Navigator:release()
  navprint("::release")
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
  return self.curr_area.name
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
  local start_area = self.start_area
  if not start_area.parent then return false end
  return start_area.parent:contains(target)
end

-- If the currently selected area is removed, move to the
-- next suitable navitem.
function Navigator:handle_removed_area(navigator, parent, removed_area)
  navprint("Navigator: handle_removed_area from "..parent.name)
  set_spaces()

  removed_area.visited = true

  if navigator.curr_area == removed_area then
    navprint("uh oh im in the removed area")
    local new_area, new_index = self:find_next_area(parent, 1)
    navigator.curr_area = new_area
    navigator.curr_area.index = new_index
    navprint("new area is "..self.curr_area.name.." at index "..self.curr_area.index)
    self:select_toggle()
  end
  remove_spaces()
end

-- Returns true if the current area exists, false if it doesn't
-- If it doesn't exist, this finds the nearest suitable area and
-- moves there
-- Needed in case of widgets with dynamic content
function Navigator:check_curr_area_exists()
  if not self.curr_area then return end
  navprint("::check_curr_area_exists: "..self.curr_area.name)
  set_spaces()

  local parent = self:parent()

  if not parent then
    navprint("the current area's parent doesn't exist - moving to root")
    self.curr_area = self.root
    --self.curr_area.index = 1
    self.curr_area:select_off_recursive()
    remove_spaces()
    return false
  elseif not parent:contains(self.curr_area) then
    navprint("the current area no longer exists - trying to find nearest neighbor")
    self.curr_area.parent:iter(1)
    self.curr_area:select_off_recursive()
    self.curr_area.visited = true
    self.curr_area.items[self.curr_area.index].visited = true
    local next_area, new_index = self:find_next_area(self.curr_area, 1)
    if not next_area then
      navprint("couldnt find next area!")
    else
      self.curr_area = next_area
      self.index = new_index
    end
    --self.curr_area = parent
    --self:iter_within(1) -- should this be 1?
    remove_spaces()
    return false
  end

  remove_spaces()
  return true
end

-- Return the next area with a suitable navitem that we can navigate to.
function Navigator:find_next_area(start_area, direction)
  navprint("::find_next_area: start area is "..start_area.name..", with index "..start_area.index..". direction is "..direction)
  set_spaces()

  start_area.visited = true
  local area = start_area

  -- determine if navigating left or right
  direction = direction > 0 and 1 or -1
  local left = direction < 0
  local right = direction > 0

  navprint("starting search through item table of "..area.name.." starting at index "..area.index.."; iterating by "..direction)
  navprint("item table has "..#area.items.." items")
  set_spaces()

  -- set bounds for iteration
  local bounds = 1
  if left then
    bounds = 1
  elseif right then
    bounds = #area.items
  else
    bounds = #area.items
  end

  navprint("bounds are ".. bounds)

  --local searching_start_area = self.start_area == area
  --local at_edge = area.index == 1 or area.index == #area.items
  --if searching_start_area and at_edge then
  --  if area.index == 1 and left then area.index = #area.items end
  --  if area.index == #area.items and right then area.index = 1 end
  --end

  -- look through area's item table for next navitem to select
  for i = area.index, bounds, direction do
    navprint("checking "..area.name.."["..i.."]:")
    area.index = i
    local item = area.items[i]

    if item.is_navitem and not item.visited then
      navprint("found suitable next navitem in "..area.name.."["..area.index.."]! returning...")
      return area, i
    elseif item.is_navitem and item.visited then
      navprint("found a navitem, but it's been visited - moving on")
    elseif item.is_area and not item.visited then
      navprint("is area called "..item.name)

      -- increment index only for direct neighbors
      local direct_neighbor = self:is_direct_neighbor(item)

      if right and direct_neighbor then
        navprint("it is a neighbor to the right. setting index to 1")
        item.index = 1
      elseif left and direct_neighbor then
        navprint("it is a neighbor to the left.")
        navprint("setting index to max")
        item.index = #item.items
      end

      if direct_neighbor then
        navprint("it is a direct neighbor of the ACTUAL starting area "..self.start_area.name)
      else
        navprint("it is NOT a direct neighbor of the ACTUAL starting area "..self.start_area.name)
      end

      return self:find_next_area(item, direction)
    elseif item.is_area and item.visited then
      navprint("is area called "..item.name..", but it has been visited already. moving on...")
    end
  end
  remove_spaces()

  -- If we get here, that means the current area has no suitable  
  -- next navitem anywhere in its item table
  -- So we need to backtrace and look in neighboring areas

  navprint("current area "..area.name.." does not have any selectable navitems - must backtrace")

  -- But if there is no parent then we can't backtrace, so
  -- force iterate within the current area.
  -- This should *ONLY* happen with the root area!
  if not area.parent then
    navprint("no parent found - cannot backtrace!")
    navprint("that means this must be the root area.")
    navprint("traversing within...")
    self.curr_area = area
    local old_index = self.curr_area.index
    self.curr_area:iter(direction)
    local new_index = self.curr_area.index

    -- if wrapping around the root,
    -- set indices accordingly
    if old_index > new_index then
      self.curr_area:reset_index_recursive()
    else
      navprint("maxing indices cause old index > new_index")
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

function Navigator:iter_between_areas(val)
  navprint("::iter_between_areas: "..self:name().." by "..val)
  set_spaces()

  --self:check_curr_area_exists()

  -- check if parent exists
  if not self:parent() then
    navprint("the current area has no parent, so we can't iterate between its areas")
    navprint("this means we're at root")
    navprint("iterating within root instead...")
    self:iter_within_area(val)
    return
  end

  navprint("calling find_next_area on parent")
  self.curr_area.visited = true
  local start_area = self:parent()

  -- the parent's currently selected item is the current area
  -- so we need to iterate the parent to make sure it doesnt search the 
  -- current area again
  navprint("iterating parent by "..val.." so we don't search the current area "..self.curr_area.name.." again")
  start_area:iter(val)

  local next_area, new_index = self:find_next_area(start_area, val)
  self.curr_area = next_area
  self.curr_area.index = new_index
  navprint("new current area is "..self:name().."["..self.curr_area.index.."]")

  remove_spaces()
end

-- Navigate within the current area's items.
-- Returns the area.
function Navigator:iter_within_area(val)
  navprint("::iter_within_area: "..self:name().." by "..val)
  set_spaces()

  --self:check_curr_area_exists()

  local area = self.curr_area
  local curr_item = self.curr_area:get_curr_item()

  -- if the current item is an area, iterate within that area
  if curr_item.is_area then
    navprint("the currently selected item is an area called "..curr_item.name..". recursing...")
    self.curr_area = curr_item
    remove_spaces()
    return self:iter_within_area(0)
  end

  -- if current item is an element, go to the next element
  if curr_item.is_navitem then
    navprint("the currently selected item is an element (at index "..area.index.."), moving to next element")

    local next_item = area:iter(val)

    -- if iterating through the current area didn't return anything, 
    -- then you need iterate to the next area.
    if not next_item then
      navprint("there was no next element within "..area.name)
      navprint("moving to the next area")
      curr_item.visited = true
      local new_area, new_index = self:find_next_area(area, val)
      self.curr_area = new_area
      self.curr_area.index = new_index
    else

      -- but if there was no next area... force iter within
      --local searching_start_area = self.start_area == area
      --local at_edge = area.index == 1 or area.index == #area.items
      --if searching_start_area and at_edge then
      --  navprint("rrrrrrrrrr")
      --  if area.index == 1 and val < 0 then area.index = #area.items end
      --  if area.index == #area.items and val > 0then area.index = 1 end
      --end

      navprint("next element found at index "..area.index)

      return area, area.index
    end
  end
end

-- When navigating between rows,
-- j/k should move to the next row.
-- Pressing tab should move to the next parent area.
function Navigator:iter_row(key, default)
  navprint("::iter_row")
  set_spaces()

  local vertical = key == "j" or key == "k"
  local horizontal = key == "h" or key == "l"
  local jump = key == "tab" or key == "backspace"

  local amt
  if key == "j" or key == "l" or key == "tab" then
    amt = 1
  else
    amt = -1
  end

  if vertical then
    local old_index = self.curr_area.index
    self:iter_between_areas(amt)
    if self.last_area.parent == self.curr_area.parent then
      self.curr_area.index = old_index
    end
  elseif horizontal then
    self:iter_within_area(amt)
  elseif jump then
    local parent = self.curr_area.parent
    local row_within_root = not (parent and parent.parent)
    local is_grid_element = parent and parent.is_grid_container
    if row_within_root or not is_grid_element then
      self:iter_between_areas(amt)
    else
      self.curr_area = self.curr_area.parent
      self:iter_between_areas(amt)
    end
  end
end

-- When navigating between columns,
-- h/l should move to the next column.
-- Pressing tab should move to the next area.
function Navigator:iter_col(key, default)
  navprint("::iter_col")
  set_spaces()
  if key == "l" then
    local old_index = self.curr_area.index
    self:iter_between_areas(1)
    if self.last_area.parent == self.curr_area.parent then
      self.curr_area.index = old_index
    end
  elseif key == "h" then
    local old_index = self.curr_area.index
    self:iter_between_areas(-1)
    if self.last_area.parent == self.curr_area.parent then
      self.curr_area.index = old_index
    end
  elseif key == "k" then
    self:iter_within_area(-1)
  elseif key == "j" then
    self:iter_within_area(1)
  elseif key == "tab" then
    local parent = self.curr_area.parent
    local row_within_root = not (parent and parent.parent)
    if row_within_root then
      self:iter_between_areas(1)
    else
      self.curr_area = self.curr_area.parent
      self:iter_between_areas(1)
    end
  elseif key == "backspace" then
    local parent = self.curr_area.parent
    local row_within_root = not (parent and parent.parent)
    if row_within_root then
      navprint("row within root")
      self:iter_between_areas(-1)
    else
      self.curr_area = self.curr_area.parent
      self:iter_between_areas(-1)
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
  navprint("::key: determining function for "..self.curr_area.name)
  set_spaces()

  self.start_area = self.curr_area
  self.start_index = self.curr_area.index
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
    if self.curr_area.is_row then
      navprint("is row!")
      self:iter_row(key)
    elseif self.curr_area.is_column then
      navprint("is col!")
      self:iter_col(key)
    elseif key == "tab" then
      self:tab()
    elseif key == "backspace" then
      self:backspace()
    else
      self:iter_within_area(default)
    end
  end
end

function Navigator:backspace()
  self.start_area = self.curr_area
  self.start_index = self.curr_area.index
  self:iter_between_areas(-1)
end

function Navigator:tab()
  self.start_area = self.curr_area
  self.start_index = self.curr_area.index
  self:iter_between_areas(1)
end

function Navigator:start()
  self.curr_area = self.root
  self:select_toggle()

  local function keypressed(_, _, key, _)
    navprint("keypressed: curr area is "..self.curr_area.name)
    self.root:reset_visited_recursive()
    self.last_area = self.curr_area
    --self:check_curr_area_exists()
    spaces = ""
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
      self:key("backspace", _)
    elseif key == "Tab" then
      if self.shift_active then
        print("shift tab")
        self:key("backspace", _)
      else
        self:key("tab", _)
      end
      --self:tab()
    elseif key == "Return" then
      self:release()
    elseif key == "Shift_L" or key == "Shift_R" then
      self.shift_active = true
    elseif key == "q" then -- debug: print current hierarchy
      print("\nDUMP: Current pos is "..self.curr_area.name.."("..self.curr_area.index..")")
      self.root:dump()
    end

    if key ~= "Return" and key ~= "q" then self:select_toggle() end
    self.last_key = "key"
    if self.last_area ~= self.curr_area and self.last_area ~= "" then
      awesome.emit_signal("nav::area_changed", self.last_area.name)
    end
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
  awesome.emit_signal("nav::area_changed", "")
  self.root:select_off_recursive()
  self.keygrabber:stop()
end

return Navigator
