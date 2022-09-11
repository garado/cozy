
-- ▀█▀ █▀█ █▀▀ █▀▀ 
-- ░█░ █▀▄ ██▄ ██▄ 

-- This is used alongside the navclasses and navigate() function
-- to move through widgets using keybinds.

-- The Tree class defines the hierarchy of the widget.
-- It contains the names of selectable elements as strings.

-- The Navclasses create signals to control the UI elements.
-- When instantiating a new navclass, you pass it the name of the
-- element as a string and the element to modify.

-- The navigate() function ties the above together - it implements 
-- a keygrabber to navigate through the tree's hierarchy and interact 
-- with its elements.

local table = table

local Tree = {
  tree = nil
}

-- Create base hierarchy
function Tree:new(levels)
  local o = {}
  o.tree = {}

  for _ = 1, levels do
    table.insert(o.tree, {})
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

function Tree:append(level, name)
  if level ~= nil and name ~= nil then
    table.insert(self.tree[level], name)
  end
end

function Tree:get_tree()
  return self.tree
end

function Tree:get_elem(level, elem)
  if self.tree[level] then
    return self.tree[level][elem]
  end
end

function Tree:reset_level(level)
  for _ = 1, #self.tree[level] do
    table.remove(self.tree[level])
  end
end

local signals = {
  "hl_toggle",
  "release",
}

local function iterate_tree(o)
  if type(o) == 'table' then
    local s
    for k,v in pairs(o) do
      s = iterate_tree(o)
    end
    return tostring(s)
  else
    return tostring(o)
  end
end

function Tree:connect_signals()
  for i = 1, #signals do
  end
end

function Tree:disconnect_signals()
  for i = 1, #signals do
  end
end

local function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

function Tree:print_contents()
  print(dump(self.tree))
end

return Tree
