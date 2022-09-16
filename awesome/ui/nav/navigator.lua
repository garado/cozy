
-- █▄░█ ▄▀█ █░█ █ █▀▀ ▄▀█ ▀█▀ █▀█ █▀█ 
-- █░▀█ █▀█ ▀▄▀ █ █▄█ █▀█ ░█░ █▄█ █▀▄ 

local awful = require("awful")
local table = table

-- For printing stacktrace
local debug_mode = true
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

local Navigator = {}
function Navigator:new(args)
  args = args or {}
  local o = {}
  o.root        = args.root or nil
  o.curr_area   = nil
  o.keygrabber  = nil
  o.rules       = args.rules or nil
  o.stack       = {}
  self.__index = self
  return setmetatable(o, self)
end

-- Action functions
function Navigator:select_toggle()
  local item = self.curr_area:get_curr_item()
  if item and not item.is_area then
    item:select_toggle()
  end
end

function Navigator:select_off() end
function Navigator:select_on() end

function Navigator:release()
  navprint("::release")
  local item = self:curr_item()
  if item and not item.is_area then
    item:release()
  end
end

-- Syntax helper functions
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

-- Stack helper functions
function Navigator:stack_push(value)
  set_spaces()
  remove_spaces()
  table.insert(self.stack, 1, value)
end

function Navigator:stack_pop()
  set_spaces()
  remove_spaces()
  local head = self.stack[1]
  table.remove(self.stack, 1)
  return head
end

function Navigator:stack_clear()
  set_spaces()
  remove_spaces()
  self.stack = {}
end

function Navigator:stack_empty()
  set_spaces()
  remove_spaces()
  return #self.stack == 0
end

-- needed for widgets with dynamic content
-- returns true if the current area exists
-- returns false if it doesn't and we had to find the nearest neighbor
function Navigator:check_curr_area_exists(direction)
  navprint("::check_curr_area_exists: "..self.curr_area.name)
  set_spaces()

  local parent = self:parent()

  if not parent then
    navprint("the current area's parent doesn't exist - moving to root")
    self.curr_area = self.root
    self.curr_area.index = 1
    remove_spaces()
    return false
  elseif not parent:contains(self.curr_area) then
    navprint("the current area no longer exists - trying to find nearest neighbor")
    self.curr_area = parent
    self:iter_within(1) -- should this be 1?
    remove_spaces()
    return false
  end

  remove_spaces()
  return true
end

function Navigator:search_area_for_next_navitem(area, index)
end

-- Abandon hope all ye who enter here
-- Return the next area with a suitable navitem that we can navigate to.
function Navigator:find_next_area(start_area, direction)
  navprint("::find_next_area: start area is "..start_area.name..", with index "..start_area.index)
  set_spaces()

  --navprint("pushing "..start_area.name.." to the stack")
  --self:stack_push(start_area)
  start_area.visited = true

 -- navprint("starting while loop through stack contents")

  --while not self:stack_empty() do
    set_spaces()
    local area = start_area
    --local area = self:stack_pop()
    --navprint("popping "..area.name.." off the stack")

    -- i may need a hl toggle somewhere here

    -- look through area for the next navitem to select
    direction = direction > 0 and 1 or -1
    local left = direction < 0
    local right = direction > 0

    navprint("starting search through item table of "..area.name.." starting at index "..area.index.."; iterating by "..direction)
    set_spaces()

    -- set bounds for iteration
    local bounds
    if left then
      bounds = 1
    elseif right then
      bounds = #area.items
    end

    for i = area.index, bounds, direction do
      navprint("checking "..area.name.."["..i.."]:")
      area.index = i
      local item = area.items[i]

      if item.is_navitem then
        navprint("found suitable next navitem in "..area.name.."["..area.index.."]! returning...")
        return area, i
      elseif item.is_area and not item.visited then
        navprint("is area called "..item.name)
        if right then
          navprint("it is a neighbor to the right.")
          item.index = 1
        elseif left then
          navprint("it is a neighbor to the left.")
          item.index = #item.items
        end

        return self:find_next_area(item, direction)
      elseif item.is_area and item.visited then
        navprint("is area called "..item.name..", but it has been visited already. moving on...")
      end
    end
    remove_spaces()

    -- if we get here, that means the current area has no selectable
    -- navitems anywhere in its children
    -- need to backtrace and look for neighboring areas

    navprint("current area "..area.name.." does not have any selectable navitems - must backtrace")

    -- but if there is no parent then we can't backtrace.
    -- just return and do nothing.
    if not area.parent then
      navprint("no parent found - cannot backtrace!")
      navprint("that means this must be the root area.")
      navprint("traversing within...")
      self.curr_area = area
      self.curr_area:iter(direction)
      return self:iter_within_area(direction)
    else
      return self:find_next_area(area.parent, direction)
    end


    remove_spaces()
  --end

  navprint("could not find next area")

  remove_spaces()
end

function Navigator:iter_between_areas(val)
  navprint("::iter_between_areas: "..self:name().." by "..val)
  set_spaces()

  self:check_curr_area_exists()

  -- toggle highlight if necessary
  if self.curr_area.widget then
    navprint("toggling highlight for the area")
    self.curr_area:select_toggle()
  end

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

  -- toggle highlight if necessary
  if self.curr_area.widget then
    navprint("toggling highlight for the area")
    self.curr_area:select_toggle()
  end


  remove_spaces()
end

-- Navigate within the current area's items.
-- Returns the area.
function Navigator:iter_within_area(val)
  navprint("::iter_within_area: "..self:name().." by "..val)
  set_spaces()

  self:check_curr_area_exists()

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
      return self:find_next_area(area, val)
    else
      navprint("next element found at index "..area.index)
      return area, area.index
    end
  end

  -- should never get here!

  remove_spaces()
end

-- Functions for handling keypresses
-- Returns rule for a specific key
function Navigator:get_rule(key)
  local box_name = self.curr_area.name
  if self.rules[box_name] and self.rules[box_name][key] then
    return self.rules[box_name][key]
  end
end

-- Gets rule for a specific key
function Navigator:key(key, default)
  local box_name = self.curr_area.name
  local rule_exists = self.rules and self.rules[box_name] and self.rules[box_name][key]
  if rule_exists then
    self:iter_within_area(self:get_rule(key))
  else
    self:iter_within_area(default)
  end
end

function Navigator:backspace()
  self:iter_between_areas(-1)
end

function Navigator:tab()
  self:iter_between_areas(1)
end

function Navigator:start()
  self.curr_area = self.root.items[1]
  self:select_toggle()

  local function keypressed(_, _, key, _)
    self.root:reset_visited_recursive()
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
      self:backspace()
    elseif key == "Tab" then
      self:tab()
    elseif key == "Return" then
      self:release()
    elseif key == "q" then -- debug: print current hierarchy
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
