
-- ▀█▀ █▀█ █▀▀ █▀▀ 
-- ░█░ █▀▄ ██▄ ██▄ 

local table = table

local Tree = {}
function Tree:new(args)
  local o = {}
end






--------------


-- Create new instance of Tree class
local Tree = { }
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
