
-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░    █▀ █▀▀ ▀█▀ █░█ █▀█ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄    ▄█ ██▄ ░█░ █▄█ █▀▀ 

local gtable = require("gears.table")
local task = {}

function task:signal_setup()
  -- █▀█ █▀▀ ▄▀█ █▀▄ █▄█ 
  -- █▀▄ ██▄ █▀█ █▄▀ ░█░ 

  -- List of tags is ready
  self:connect_signal("ready::tag_names", function()
    if self:initializing() then
      self.inits_complete = self.inits_complete + 1
      self:set_focused_tag()
      self:parse_tasks_for_tag(self.focused_tag)
    end
    self:report_focused('ready::tag_names signal')
    self:emit_signal("taglist::update")
  end)

  -- List of projects for a tag is ready
  self:connect_signal("ready::project_names", function(_, tag)
    if self:initializing() then
      self.inits_complete = self.inits_complete + 1
      self.focused_project = nil
      self:set_focused_project(tag, nil)
    end
    if not self.focused_project then
      self:set_focused_project(tag, nil)
    end
    self:report_focused('ready::project_names signal')
    self:emit_signal("tasklist::update", tag, self.focused_project)
  end)

  -- All project information is ready (project list and total tasks per project)
  self:connect_signal("ready::project_information", function(_, tag)
    if self:initializing() then
      -- add 2 because this initializes the header and project list components
      self.inits_complete = self.inits_complete + 2
    end
    self:report_focused('readty::projects signal')
    self:emit_signal("projects::update", tag)
    self:emit_signal("header::update", tag, self.focused_project)
  end)

  -- Emitted after parse_tasks_for_project() has completed.
  -- (This is not emitted during initialization. During initialization, 
  -- project tasks are parsed from parse_tasks_for_tag.)
  self:connect_signal("ready::project_tasks", function(_, tag, project)
    if project == self.focused_project then
      self:emit_signal("tasklist::update", tag, project)
    end
    self:parse_total_tasks_for_project(tag, project)
  end)


  -- █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀ █▀▀ █▀▄ 
  -- ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░ ██▄ █▄▀ 

  self:connect_signal("selected::tag", function(_, tag)
    if tag == self.focused_tag then return end
    self.focused_tag     = tag
    self.focused_project = nil

    -- Check if tasks need to be parsed
    if not self.tags[tag] then
      self:parse_tasks_for_tag(tag)
    else
      self:set_focused_project(tag, nil)
      self:emit_signal("projects::update", tag)
      self:emit_signal("tasklist::update", tag, self.focused_project)
      self:emit_signal("header::update", tag, self.focused_project)
    end
  end)

  self:connect_signal("selected::project", function(_, project)
    self.focused_project = project
    self:report_focused()
    self:emit_signal("header::update", self.focused_tag, self.focused_project)
    self:emit_signal("tasklist::update", self.focused_tag, project)
  end)


  -- █ █▄░█ █▀█ █░█ ▀█▀ 
  -- █ █░▀█ █▀▀ █▄█ ░█░ 

  self:connect_signal("input::complete", self.execute_command)


  -- █▀▄▀█ █ █▀ █▀▀ 
  -- █░▀░█ █ ▄█ █▄▄ 

  self:connect_signal("toggle_show_waiting", function()
    self.show_waiting = not self.show_waiting
    self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
    self:emit_signal("header::update", self.focused_tag, self.focused_project)
  end)
end

return function(_task)
  gtable.crush(_task, task, true)
end
