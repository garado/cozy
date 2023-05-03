
-- █░█ █ 
-- █▄█ █ 

local awful   = require("awful")
local strutil = require("utils.string")
local gtable  = require("gears.table")

local task = {}

function task:ui_signal_setup()
  self:connect_signal("selected::tag", function(_, tag)
    self:dbprint('Selected tag '..tag)
  end)

  self:connect_signal("selected::project", function(_, tag, project)
    self:dbprint('Selected project '..project)
  end)
end

return function(_task)
  gtable.crush(_task, task)
end
