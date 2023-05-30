
-- █░█ █ 
-- █▄█ █ 

local gtable  = require("gears.table")

local task = {}

function task:ui_signal_setup()
  self:connect_signal("selected::tag", function(_, tag)
    self:dbprint('Selected tag '..tag)
    self.active_project = self.data[tag][1]
    self:emit_signal("selected::project", tag, self.data[tag][1])
  end)

  self:connect_signal("selected::project", self.fetch_pending_tasks_for_project)

  self:connect_signal("refresh", function()
    self.restore = {
      tag     = self.active_tag,
      project = self.active_project,
      id      = self.active_task.id,
    }
    self:fetch_tags_and_projects()
  end)
end

return function(_task)
  gtable.crush(_task, task)
end
