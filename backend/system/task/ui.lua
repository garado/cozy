
-- █░█ █ 
-- █▄█ █ 

local gtable  = require("gears.table")

local task = {}

function task:ui_signal_setup()
  self:connect_signal("selected::tag", function(_, tag)
    self:dbprint('Selected tag '..tag)
    self:emit_signal("selected::project", tag, self.data[tag][1])
  end)

  self:connect_signal("selected::project", self.fetch_pending_tasks_for_project)

  self:connect_signal("refresh", function()
    self:fetch_tags_and_projects()
  end)
end

return function(_task)
  gtable.crush(_task, task)
end
