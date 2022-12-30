
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- For interfacing with Taskwarrior.

-- TODO
-- rename get_focused_project to getfocusedprojectname

-- Organization
-- ----------------
-- self._private.focused_tag
--      - string containing name of focused tag
-- self._private.focused_project
--      - string containing name of focused project
-- self._private.focused_task
--      - reference to focused task json table
-- self._private.tags[]
--      - array of all active tags
-- self._private.tags[tag].projects_ready
--      - an int used for backend stuff only (do not touch)
--      - for each project there is another async call to get the total # of tasks, both completed and pending
--      - this counts how many of those async calls have been completed
--      - once (# async calls completed == # projects), the UI updates
-- self._private.tags[tag].projects[]
--      - array of all active projects for a given tag
-- self._private.tags[tag].projects[proj].tasks
--      - array of all tasks for a given project (numerically indexed)

-- Signals      Description
-- ---------    ------------------
-- ready        Emitted by core when data is ready
-- selected     Emitted by UI/keyboard navigation when user selects something
-- update       Emitted by core and caught by UI; tells UI to update

-- Signals used       Args      Emitted when
-- -------------      -------   ---------------
-- ready::tags        -         taglist has been parsed
-- ready::tasks       tag       all tasks for a given tag have been parsed
-- ready::projects    tag       project information retrieved (all tasks + total all-time tasks)
-- selected::tag      tag       a new tag has been selected (enter'd) in task manager
-- selected::project  project   a new project has been selected (enter'd) in task manager

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local json    = require("modules.json")
local core    = require("helpers.core")
local gears   = require("gears")
local config  = require("config")

local debug   = require("core.debug")
-- debug:off()

local task = { }
local instance = nil

---------------------------------------------------------------------

-- █▀█ ▄▀█ █▀█ █▀ █▀▀ 
-- █▀▀ █▀█ █▀▄ ▄█ ██▄ 

-- These functions call Taskwarrior commands and then parse/store the json output.

-- Currently unused
function task:parse_contexts()
  local cmd = "task context | head -n -2 | tail -n +4"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local contexts = {}
    local lines = core.split('\r\n', stdout)
    for i = 1, #lines do
      local fields = core.split(' ', lines[i])
    end
  end)
end

--- Parse all tags
function task:parse_tags()
  local cmd = "task tag | head -n -2 | tail -n +4 | cut -f1 -d' ' "
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tags = core.split('\r\n', stdout)
    self._private.tags = tags
    self._private.tag_names = tags
    self:emit_signal("ready::tags")
  end)
end

--- Parse all pending tasks for a given tag and then sort them by project
-- (As far as I'm aware this is the only way to initially obtain the list of projects for a tag) 
function task:parse_tasks_for_tag(tag)
  local cmd = "task context none; task tag:"..tag.. " status:pending export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local empty_json = "[\n]\n"
    if stdout ~= empty_json and stdout ~= "" then
      local json_arr = json.decode(stdout)

      -- Separate tasks by project
      local projects = {}
      local project_names = {}
      for i, v in ipairs(json_arr) do
        local proj = json_arr[i]["project"] or "No project"
        if not projects[proj] then
          projects[proj] = {}
          projects[proj].tasks = {}
          projects[proj].total = 0
          project_names[#project_names+1] = proj
          self:parse_total_tasks_for_proj(tag, proj)
        end
        table.insert(projects[proj].tasks, v)
      end

      self._private.tags[tag] = {}
      self._private.tags[tag].projects = projects
      self._private.tags[tag].projects_ready = 0
      self._private.tags[tag].project_names = project_names

      self:emit_signal("ready::tasks", tag)
      self:emit_signal("ready::project_list", tag)
    end
  end)
end

-- TODO
--- Parse all pending tasks for a given project within a given tag
function task:parse_tasks_for_project(tag, project)
  local cmd = "task tag:"..tag.." proj:'"..project.."' status:pending export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local empty_json = "[\n]\n"
    if stdout ~= empty_json and stdout ~= "" then
      local json_arr = json.decode(stdout)
      core.print_arr(json_arr)
    end
  end)
end

--- Parse total number of tasks for a project - pending and completed
function task:parse_total_tasks_for_proj(tag, proj)
  local unset_context = "task context none ; "
  local filters = "task tag:'"..tag.."' project:'"..proj.."' "
  local status = " '(status:pending or status:completed)' "
  local cmd = unset_context .. filters .. status .. "count"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local total = tonumber(stdout) or 0
    self._private.tags[tag].projects[proj].total = total

    local ready = self._private.tags[tag].projects_ready + 1
    if ready == self:num_projects_in_tag(tag) then
      self:emit_signal("ready::projects", tag)
    end
    self._private.tags[tag].projects_ready = ready
  end)
end

---------------------------------------------------------

-- █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

--- Returns the number of projects in a tag
function task:num_projects_in_tag(tag)
  local tbl = self._private.tags[tag].projects
  return gears.table.count_keys(tbl)
end

--- For debugging purposes.
function task:report_focused()
  local curtag = self._private.focused_tag or "NIL"
  local curproj = self._private.focused_project or "NIL"
  debug:print("\tcore::task: focused tag is "..curtag..", focused proj is "..curproj)
end

--- Verify that the default tag (set in config.lua) actually exists. 
function task:verify_default_tag()
  local dtag = config.tasks.default_tag
  debug:print('\tdefault tag is '..dtag)
  local tags = self._private.tags
  for i = 1, #tags do
    if tags[i] == dtag then return true end
  end
end

function task:set_focused_tag(tag)
  -- No tag is given, so this is the startup call
  if not tag then
    if self:verify_default_tag() then
      self._private.focused_tag = config.tasks.default_tag
      debug:print('\tverified default tag does exist - continuing')
      self:parse_tasks_for_tag(self:focused_tag())
    else
      debug:print('\tdefault tag does NOT exist - setting to 1st tag...')
      -- TODO!!!
    end
  end

  if tag then
    self._private.focused_tag = tag
  end
end

-- TODO
function task:verify_default_project(tag)
end

-- TODO set default project
function task:set_focused_project(tag, project)
  if not project then
    -- Set focused project to first project in list
    local proj = self:get_projects(tag)
    for k, _ in pairs(proj) do
      self._private.focused_project = k
      break
    end
  end

  if project then
    self._private.focused_project = project
  end
end

function task:set_focused_task(_task, index)
  debug:print('core::setfocusedtask to index '..index..', desc '.._task["description"])
  self._private.focused_task = _task
  self._private.old_task_index = self._private.task_index
  self._private.task_index   = index
end

function task:increment_total_tasks(tag, project)
  local total = self._private.tags[tag].projects[project].total
  self._private.tags[tag].projects[project].total = total + 1
end

function task:decrement_total_tasks(tag, project)
  local total = self._private.tags[tag].projects[project].total
  self._private.tags[tag].projects[project].total = total - 1
end

function task:get_task_at(tag, project, index)
  return self._private.tags[tag].projects[project].tasks[index]
end

---------------------------------------------------------------------

-- █▀▀ █▀▀ ▀█▀ ▀█▀ █▀▀ █▀█ █▀ ░░▄▀ █▀ █▀▀ ▀█▀ ▀█▀ █▀▀ █▀█ █▀ 
-- █▄█ ██▄ ░█░ ░█░ ██▄ █▀▄ ▄█ ▄▀░░ ▄█ ██▄ ░█░ ░█░ ██▄ █▀▄ ▄█ 

function task:old_focused_task_index() return self._private.old_task_index end
function task:focused_task_index() return self._private.task_index end
function task:focused_task()  return self._private.focused_task end

function task:focused_tag_index() return self._private.tag_index end
function task:focused_tag()   return self._private.focused_tag  end
function task:tags()          return self._private.tags         end

function task:focused_project_index() return self._private.project_index end
function task:focused_project() return self._private.focused_project end

function task:projects(tag)
  if not self._private.tags[tag] then return end
  return self._private.tags[tag].projects
end

-- TODO handle proper removal of elements when a task is deleted
--- Return the names of all tags
function task:tag_names()
  return self._private.tag_names
end

--- Return the names of all projects
function task:project_names(tag)
  if not self._private.tags[tag] then return end
  return self._private.tags[tag].project_names
end

--- everything below here needs to be refactored or renamed

function task:get_tags()  return self._private.tags end

function task:get_projects(tag)
  return self._private.tags[tag].projects
end

function task:get_focused_tag()     return self._private.focused_tag  end
function task:get_focused_project() return self._private.focused_project end
function task:get_focused_task()    return self._private.focused_task end

function task:get_focused_task_desc()
  return self._private.focused_task["description"]
end

function task:get_pending_tasks(tag, proj)
  tag   = tag  or self._private.focused_tag
  proj  = proj or self._private.focused_project
  return self._private.tags[tag].projects[proj].tasks
end

function task:get_total_tasks(tag, proj)
  tag   = tag  or self._private.focused_tag
  proj  = proj or self._private.focused_project
  return self._private.tags[tag].projects[proj].total
end

function task:get_proj_completion_percentage(tag, proj)
  tag = tag or self._private.focused_tag

  local pending = #self._private.tags[tag].projects[proj].tasks
  local total = self._private.tags[tag].projects[proj].total
  local completed = total - pending
  return math.floor((completed / total) * 100) or 0
end

-- BUG: every accent is turning bright red for some reason
function task:set_accent(tag, project, color)
  self._private.tags[tag].projects[project].accent = color
end

function task:get_accent(tag, project)
  if self._private.tags[tag] == nil then
    print('tags nil')
  elseif self._private.tags[tag].projects == nil then
    print('proj nil')
  end
  return self._private.tags[tag].projects[project].accent
end

---------------------------------------------------------------------

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- Sets up the signals used to interact with UI and keyboard inpu.

function task:signal_setup()

  -- █▀█ █▀▀ ▄▀█ █▀▄ █▄█ 
  -- █▀▄ ██▄ █▀█ █▄▀ ░█░ 

  -- Tag list is ready
  self:connect_signal("ready::tags", function()
    debug:print('core::task: caught signal ready::tags')
    self:set_focused_tag()
    self:report_focused()
    self:emit_signal("taglist::update_all")
  end)

  -- All tasks for a given tag are ready
  self:connect_signal("ready::tasks", function(_, tag)
    debug:print('core::task: caught signal ready::tasks for '..tag)
    self:report_focused()
  end)

  -- List of active projects for a tag are ready
  self:connect_signal("ready::project_list", function(_, tag)
    debug:print('core::task: caught signal ready::project_list for '..tag)
    self:set_focused_project(tag)
    self:parse_total_tasks_for_proj(tag, self:focused_project())
    self:report_focused()
    -- self:emit_signal("project_list::update_all", tag)
    self:emit_signal("update::tasks", tag, self:focused_project())
  end)

  -- All project information is ready (active project list and total tasks per
  -- active project)
  self:connect_signal("ready::projects", function(_, tag)
    debug:print('core::task: caught signal ready::projects for '..tag)
    self:emit_signal("project_list::update_all", tag)
    self:emit_signal("header::update", tag, self:focused_project())
  end)

  -- █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀ █▀▀ █▀▄ 
  -- ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░ ██▄ █▄▀ 

  self:connect_signal("selected::tag", function(_, tag)
    debug:print('core::task: caught selected::tag for '..tag)
    if tag == self:focused_tag() then return end

    self._private.focused_tag = tag
    self._private.focused_project = nil

    -- Check if tasks need to be parsed
    if not self._private.tags[tag] then
      debug:print('\ttasks for selected tag are not ready; parsing them...')
      self:parse_tasks_for_tag(tag)
    else
      self:set_focused_project(tag, nil)
      debug:print('\ttasks for selected tag have already been fetched! updating ui')
      self:emit_signal("project_list::update_all", tag)
      self:emit_signal("update::tasks", tag, self:focused_project())
      self:emit_signal("header::update", tag, self:focused_project())
      self:report_focused()
    end
  end)

  self:connect_signal("selected::project", function(_, project)
    debug:print('core::task: caught selected::project for '..project)
    self:set_focused_project(nil, project)
    self:emit_signal("update::tasks", self:focused_tag(), project)
    self:emit_signal("header::update", self:focused_tag(), project)
    self:report_focused()
  end)

  self:connect_signal("selected::task", function(_, task)
    debug:print('core::task: caught selected::task')
  end)

  -- █▀▄▀█ █▀█ █▀▄ █ █▀▀ █ █▀▀ █▀▄ 
  -- █░▀░█ █▄█ █▄▀ █ █▀░ █ ██▄ █▄▀ 

  -- Modify data tables, then selectively reload components based on what was just modified

  -- Task added
  self:connect_signal("modified::add", function(_, tag, project, input, id)
    debug:print('core::task: caught mod add signal with input '..input)

    -- Create new task entry and insert into local database
    local new_task = {}
    new_task["description"] = input
    new_task["tag"] = tag
    new_task["project"] = project
    new_task["id"] = id

    table.insert(self._private.tags[tag].projects[project].tasks, new_task)
    self:increment_total_tasks(tag, project)

    -- Update UI
    self:emit_signal("tasklist::add", new_task)
    self:emit_signal("header::update", tag, project)
    self:emit_signal("project_list::update", tag, project)
  end)

  -- Task done
  self:connect_signal("modified::done", function(_, tag, project, _, _)
    -- Remove task from local database
    local index = self:focused_task_index()
    debug:print('core::task: caught mod done signal for task at ui index '..index)
    table.remove(self._private.tags[tag].projects[project].tasks, index)

    -- Update UI
    self:emit_signal("tasklist::remove")
    self:emit_signal("header::update", tag, project)
    self:emit_signal("project_list::update", tag, project)
  end)

  -- Task deleted: remove task entry and decrement total count
  self:connect_signal("modified::delete", function(_, tag, project)
    local index = self:focused_task_index()
    table.remove(self._private.tags[tag].projects[project].tasks, index)
    self:decrement_total_tasks(tag, project)

    debug:print('core::task: caught mod delete signal for task at ui index '..index)

    -- Update UI
    self:emit_signal("tasklist::remove")
    self:emit_signal("header::update", tag, project)
    self:emit_signal("project_list::update", tag, project)
  end)

  --- TODO: the user input is not in the format that the format_due_date function
  -- expects (should look like YYYYMMDDT#########Z); need to convert
  self:connect_signal("modified::mod_due", function(_, tag, project, input, id)
    debug:print('core::task: caught mod due signal')
    local modtask = self:get_task_at(tag, project, self:focused_task_index())
    print('NEW ID IS '..id)
    -- modtask["due"] = input
    -- self:emit_signal("tasklist::update_task_name", index, input)
  end)

  -- Task description (aka task name) modified
  self:connect_signal("modified::mod_name", function(_, tag, project, input, _)
    debug:print('core::task: caught mod name signal')
    local index   = self:focused_task_index()
    local modtask = self:get_task_at(tag, project, index)
    modtask["description"] = input
    self:emit_signal("tasklist::update_task_name", index, input)
  end)

  -- Task start/stop toggle
  self:connect_signal("modified::start", function(_, tag, project)
    debug:print('core::task: caught mod start signal')
    local index   = self:focused_task_index()
    local modtask = self:get_task_at(tag, project, index)

    -- The start field when exported from Taskwarrior contains the timestamp of when the task
    -- was started, but for our purposes we never use that - we just need to know IF is is started
    local is_started = modtask["start"]
    if is_started then
      modtask["start"] = nil
    else
      modtask["start"] = true
    end

    self:emit_signal("tasklist::update_start", index, modtask["description"], is_started)
  end)

  -- Tag changed: remove task from current tag and append to new tag
  -- The tasks's project will remain the same
  self:connect_signal("modified::mod_tag", function(_, old_tag, project, new_tag)
    local index   = self:focused_task_index()
    local modtask = self:get_task_at(old_tag, project, index)

    debug:print('core::task: caught mod tag signal for task at ui index '..index)

    local focus_new_tag = false

    -- Last task remaining in the tag
    if #self:get_pending_tasks(old_tag, project) == 1 then
      focus_new_tag = true
      self:emit_signal("taglist::remove", old_tag)
    end

    -- TODO what if it's the last task remaining in a project
    -- TODO what if it's the last task remaining in a tag

    -- Create tag table if it doesn't exist already
    if not self._private.tags[new_tag] then
      print('tag does not exist - creating')
      self._private.tags[new_tag] = {}
      self._private.tags[new_tag].projects_ready = 0
      self._private.tags[new_tag].projects = {}
      self._private.tags[new_tag].projects[project] = {}
      self._private.tags[new_tag].projects[project].tasks = {}
      self._private.tags[new_tag].projects[project].total = 0
      self:emit_signal("taglist::add", new_tag)
      focus_new_tag = true
    end

    -- Insert task into new tag table
    table.insert(self._private.tags[new_tag].projects[project].tasks, modtask)
    self:increment_total_tasks(new_tag, project)

    -- Remove from old tag table
    table.remove(self._private.tags[old_tag].projects[project].tasks, index)
    self:decrement_total_tasks(old_tag, project)

    -- Update UI
    self:emit_signal("tasklist::remove")

    if focus_new_tag then
      self:emit_signal("selected::tag", new_tag)
    else
      self:emit_signal("header::update", old_tag, project)

      -- Update completion percentages
      self:emit_signal("project_list::update", old_tag, project)
      self:emit_signal("project_list::update", new_tag, project)
    end
  end)

  -- Project changed: remove project from current tag and append to new 
  self:connect_signal("modified::mod_proj", function(_, tag, old_project, new_project, _)
    local index   = self:focused_task_index()
    local modtask = self:get_task_at(tag, old_project, index)

    debug:print('core::task: caught mod proj signal; new project is '..new_project)

    local focus_new_project = false

    -- Last task remaining in the tag
    if #self:get_pending_tasks(tag, old_project) == 1 then
      focus_new_project = true
      self:emit_signal("project_list::remove", old_project)
    end

    -- TODO what if it's the last task remaining in a project
    -- TODO what if it's the last task remaining in a tag

    -- Create project table if it doesn't exist already
    if not self._private.tags[tag].projects[new_project] then
      print('project '..new_project..' does not exist - creating')
      self._private.tags[tag].projects[new_project] = {}
      self._private.tags[tag].projects[new_project].tasks = {}
      self._private.tags[tag].projects[new_project].total = 0
      self:emit_signal("project_list::add", new_project)
      focus_new_project = true
    end

    -- Insert task into new project table
    table.insert(self._private.tags[tag].projects[new_project].tasks, modtask)
    self:increment_total_tasks(tag, new_project)

    -- Remove from old project table
    table.remove(self._private.tags[tag].projects[old_project].tasks, index)
    self:decrement_total_tasks(tag, old_project)

    -- Update UI
    self:emit_signal("tasklist::remove")

    if focus_new_project then
      self:emit_signal("selected::project", new_project)
    else
      self:emit_signal("header::update", tag, new_project)

      -- Update completion percentages
      self:emit_signal("project_list::update", tag, old_project)
      self:emit_signal("project_list::update", tag, new_project)
    end
  end)
end

function task:reset()
  self._private.tags = {}
  self._private.focused_tag   = nil
  self._private.focused_project  = nil
  self._private.focused_task  = nil
  self._private.task_index = 0
  self._private.project_index = 0
  self._private.tag_index = 0
  self:parse_tags()
end

-- Startup
function task:new()
  self._private.tags = {}
  self._private.focused_tag   = nil
  self._private.focused_project  = nil
  self._private.focused_task  = nil
  self._private.task_index = 0
  self._private.project_index = 0
  self._private.tag_index = 0
  self:parse_tags()
  self:signal_setup()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, task, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
