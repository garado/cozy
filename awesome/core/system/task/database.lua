
-- █▀▄ ▄▀█ ▀█▀ ▄▀█ █▄▄ ▄▀█ █▀ █▀▀ 
-- █▄▀ █▀█ ░█░ █▀█ █▄█ █▀█ ▄█ ██▄ 

-- These functions work with data that core.task has already parsed

local beautiful = require("beautiful")
local gtable = require("gears.table")
local config = require("cozyconf")
local task   = {}

--- Sort projects alphabetically
function task:sort_projects(tag)
  table.sort(self.tags[tag].project_names, function(a, b)
    return a < b
  end)
end

-- Sort tasks by due date, then alphabetically 
function task:sort_task_descriptions(tag, project)
  table.sort(self.tags[tag].projects[project].tasks, function(a, b)
    -- If neither have due dates or they have the same due date,
    -- then sort alphabetically
    if (not a.due and not b.due) or (a.due == b.due) then
      return a.description < b.description
    end

    -- Nearest due date should come first
    if a.due and not b.due then
      return true
    elseif not a.due and b.due then
      return false
    else
      return a.due < b.due
    end
  end)
end

-- A bunch of helper functions for data management
function task:add_new_project(tag, new_project)
  self.tags[tag].projects[new_project] = {}
  self.tags[tag].projects[new_project].tasks  = {}
  self.tags[tag].projects[new_project].total  = 0
  self.tags[tag].projects[new_project].accent = beautiful.random_accent_color()
  local pnames = self.tags[tag].project_names
  pnames[#pnames+1] = new_project
end

-- Avoid duplicate tag names
function task:add_tag_name(new_tag)
  for i = 1, #self.tag_names do
    if self.tag_names[i] == new_tag then return end
  end
  local tnames = self.tag_names
  tnames[#tnames+1] = new_tag
end

function task:add_new_tag(new_tag)
  self.tags[new_tag] = {}
  self.tags[new_tag].projects = {}
  self.tags[new_tag].project_names  = {}
  self.tags[new_tag].projects_ready = 0
  self:add_tag_name(new_tag)
end

function task:delete_tag(tag_to_delete)
  for i = 1, #self.tag_names do
    if self.tag_names[i] == tag_to_delete then
      table.remove(self.tag_names, i)
      break
    end
  end
  self.tags[tag_to_delete] = nil
end

function task:delete_project(tag, project_to_delete)
  if not self.tags[tag] then return end
  self.tags[tag].projects[project_to_delete] = nil
  local pnames = self.tags[tag].project_names
  for i = 1, #pnames do
    if pnames[i] == project_to_delete then
      table.remove(pnames, i)
      return
    end
  end
end

function task:adjust_project_total(tag, project, amt)
  self.tags[tag].projects[project].total = self.tags[tag].projects[project].total + amt
end

function task:selective_reload(type, input)
  -- Flag detected by tasklist; used when restoring nav position after reloading
  -- the focused project
  self.restore_required = true

  local ft = self.focused_tag
  local fp = self.focused_project
  local ftask = self.focused_task
  local ntasks = #self.tags[ft].projects[fp].tasks
  local nproj  = #self.tags[ft].project_names

  -- Command types that remove a task from the focused project.
  local remove_task_type = type == "done" or type == "delete"

  if type == "mod_tag"  and input == ft then return end
  if type == "mod_proj" and input == fp then return end

  -- Move focused task to other project within tag
  if type == "mod_proj" then
    local new_project = input

    -- Create project if necessary + move task
    if not self.tags[ft].projects[new_project] then
      self:add_new_project(ft, new_project)
    end

    table.insert(self.tags[ft].projects[new_project].tasks, ftask)
    table.remove(self.tags[ft].projects[fp].tasks, self.task_index)
    self:sort_task_descriptions(ft, new_project)
    self:adjust_project_total(ft, new_project, 1) -- total tasks++ for new proj
    self:adjust_project_total(ft, fp, -1) -- total tasks-- for old proj

    -- If necessary, delete old focused project and set new one
    if ntasks == 1 then
      self:delete_project(ft, fp)
      self.focused_project = new_project
    end

    self:emit_signal("tasklist::update", ft, self.focused_project)
    self:emit_signal("projects::update", ft, self.focused_project)
    self:emit_signal("header::update", ft, self.focused_project)
  end

  -- Move focused task to other tag
  if type == "mod_tag" then
    local new_tag = input

    -- Create tag/project if necessary + move task
    if not self.tags[new_tag] then
      self:add_new_tag(new_tag)
    end

    if not self.tags[new_tag].projects[fp] then
      self:add_new_project(new_tag, fp)
    end

    table.insert(self.tags[new_tag].projects[fp].tasks, ftask)
    table.remove(self.tags[ft].projects[fp].tasks, self.task_index)
    self:sort_task_descriptions(new_tag, fp)
    self:adjust_project_total(new_tag, fp, 1) -- total tasks++ for new proj
    self:adjust_project_total(ft, fp, -1) -- total tasks-- for old proj

    if ntasks == 1 and nproj == 1 then
      -- Since ntask == 1 and nproj == 1, moving this task means the focused project and tag gets erased
      self:delete_tag(ft)
      self.focused_tag = new_tag
      self.focused_project = fp
    elseif ntasks == 1 and nproj > 1 then
      -- Since ntasks == 1 and nproj > 1, moving this task means the focused project gets erased
      -- Focus follows moved task
      self:delete_project(ft, fp)
      self.focused_tag = new_tag
      self.focused_project = fp
    end

    self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
    self:emit_signal("taglist::update", self.focused_tag, self.focused_project)
    self:emit_signal("projects::update", self.focused_tag, self.focused_project)
    self:emit_signal("header::update", self.focused_tag, self.focused_project)
  end

  if remove_task_type and ntasks == 1 and nproj == 1 then
    -- Since ntasks == 1 and nproj == 1, the focused tag and project get erased
    self:delete_tag(ft)
    self.focused_tag = nil
    self.focused_project = nil
    self:set_focused_tag()
    self:set_focused_project(self.focused_tag, nil)

    self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
    self:emit_signal("taglist::update", self.focused_tag, self.focused_project)
    self:emit_signal("projects::update", self.focused_tag, self.focused_project)
    self:emit_signal("header::update", self.focused_tag, self.focused_project)
  end

  if remove_task_type and ntasks == 1 then
    if nproj == 1 then
      -- Since ntasks == 1 and nproj == 1, delete focused tag/project
      self:delete_tag(ft)
      self.focused_tag = nil
      self.focused_project = nil
      self:set_focused_tag()
      self:set_focused_project(self.focused_tag, nil)
      self:emit_signal("taglist::update", self.focused_tag, self.focused_project)
    elseif nproj > 1 then
      -- Since ntasks == 1 and nproj > 1, delete focused project
      self:delete_project(ft, fp)
      self.focused_project = nil
      self:set_focused_project(self.focused_tag, nil)
    end

    self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
    self:emit_signal("projects::update", self.focused_tag, self.focused_project)
    self:emit_signal("header::update", self.focused_tag, self.focused_project)
  end

  if remove_task_type and (ntasks > 1) then
    self:parse_tasks_for_project(ft, fp)
  end

  -- If none of the other cases happen, then just reload current project
  if not (remove_task_type) and not (type == "mod_proj") and not (type == "mod_tag") then
    self:parse_tasks_for_project(ft, fp)
  end
end

--- Sets the focused tag to the given tag.
-- If a tag is not provided: 
--    If focused tag is already set, do nothing.
--    If default tag (in config) exists, set to that.
--    Otherwise set to first tag in tag list.
function task:set_focused_tag(tag)
  if tag then self.focused_tag = tag return end
  if self.focused_tag then return end

  local deftag = config.tasks.default_tag
  local deftag_data_exists = false
  for i = 1, #self.tag_names do
    if self.tag_names[i] == deftag then
      deftag_data_exists = true
      break
    end
  end

  if not self.focused_tag then
    if deftag and deftag_data_exists then
      self.focused_tag = config.tasks.default_tag
    else
      self.focused_tag = self.tag_names[1]
    end
  end
end

--- Sets the focused project to the given project.
-- If a project is not provided, set to the default project.
-- If default project does not exist, set to first project in the project list.
function task:set_focused_project(tag, project)
  if project then
    self.focused_project = project
  elseif not self.focused_project then
    local defproject = config.tasks.default_project
    if defproject and self.tags[tag].projects[defproject] then
      self.focused_project = defproject
    else
      self.focused_project = self.tags[tag].project_names[1]
    end
  end
end

-- Misc calculations

function task:calc_completion_percentage(tag, project)
  tag = tag or self.focused_tag

  local pending   = #self.tags[tag].projects[project].tasks
  local total     = self.tags[tag].projects[project].total
  local completed = total - pending

  return math.floor((completed / total) * 100) or 0
end

function task:set_focused_task(task_table, index)
  self.focused_task = task_table
  self.old_task_index = self.task_index
  self.task_index   = index
end

function task:get_accent(tag, project)
  return self.tags[tag].projects[project].accent
end


function task:set_accent(tag, project, accent)
  self.tags[tag].projects[project].accent = accent
end

return function(_task)
  gtable.crush(_task, task, true)
end
