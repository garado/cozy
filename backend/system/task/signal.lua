
-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- This entire module is asynchronous and therefore signal-driven.

local gtable = require("gears.table")

-- SIGNAL NAME      PARAMETERS    DESCRIPTION
-- ready::tags      -             All tags have been parsed
-- ready::projects  tag           All projects for the given tag have been parsed
-- ready::tasks     tag, project  All tasks for a given project in a tag have been parsed

local task = {}

function task:signal_setup()

  -- Get data for just the first tag
  self:connect_signal("ready::tags", function()
    for tag in pairs(self.data) do
      self:fetch_projects_for_tag(tag)
      break
    end
  end)

  self:connect_signal("ready::projects", function(_, tag)
  end)
end

return function(_task)
  gtable.crush(_task, task)
end
