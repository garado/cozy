
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- For interfacing with Taskwarrior.
-- The way this entire module is written is so fucking confusing lmao sorry but
-- I have provided as much documentation as I can

-- SIGNALS            EMITTED WHEN
-- --------------     -----------------
-- ready::tag_names        Tags have been parsed
-- ready::project_information    Projects for a given tag have been parsed
-- selected::tag      A tag has been selected (emitted in tags.lua)
-- selected::project  A project has been selected (emitted in projects.lua)
-- input::request     A valid keybind is pressed. Triggers awful.prompt. (handled in prompt.lua)
-- input::complete    User has completed input. (emitted by prompt.lua, caught here)

-- STRUCTURE: VARS
-- -------------------
-- # focused_tag     : (string) name of currently focused tag
-- # focused_project : (string) name of currently focused project
-- # focused_task    : (table) json data parsed from taskwarrior
-- # task_index      : (int) current nav_tasklist position (used for scrolling + restore)
-- # old_task_index  : (int) previous nav_tasklist position (used for scrolling)
-- # projects_ready  : (int) used for backend only
--      - for each project there is another async call to get the total # of tasks (both completed and pending)
--      - this counts how many of those async calls have been completed
--      - once (# async calls completed == # projects), the relevant UI components update

-- STRUCTURE: TASKWARRIOR DATA
-- -------------------------------
-- # tag_names : (table) all active tags, indexed numerically
-- # tags{}    : (table) all active tags, indexed by tag name
  -- # projects_ready : (int) number of projects have their total task count available
  -- # project_names  : (table of strings) all active project names
  -- # projects{} : table of all active projects associated with tag, indexed by project name
    -- # tasks{}  : table of all active tasks in project, indexed numerically

-- INITIALIZATION PIPELINE
-- ---------------------------
-- At module initialization, init flag is set to true
-- After every stage, inits_complete--
-- Once inits_complete == NUM_COMPONENTS, initialization has completed
--                
--                 ready::  ┌────────────┐     ready::tasks     ┌─────────────────────┐       ready::
--  ┌────────────┐tag_names │parse_tasks_│ ready::project_names │ parse_total_tasks_  │ project_information     init
--  │parse_tags()│───┬─────►│ for_tags() │──────────┬─────────► │    for_project()    │─────────┬───────────► complete!
--  └────────────┘   ▼      └────────────┘          ▼           └─────────────────────┘         ▼
--               UI update:                     UI update:                                  UI update:
--                  tags                         tasklist                               header, project list

local gobject   = require("gears.object")
local gtable    = require("gears.table")
local awful     = require("awful")
local json      = require("modules.json")
local core      = require("helpers.core")
local config    = require("config")
local time      = require("core.system.time")
local beautiful = require("beautiful")

local debug   = require("core.debug")
-- debug:off()

local task = {}
local instance = nil

local EMPTY_JSON = "[\n]\n"
local NUM_COMPONENTS = 4

local inits_complete = 0
local function initializing()
  return not (inits_complete == NUM_COMPONENTS)
end

--------------------------------

-- For debugging
function task:report_focused(src)
  local curtag = self.focused_tag or "NIL"
  local curproj = self.focused_project or "NIL"
  src = (src and ' from ' .. src) or ""
end

-- █ █▄░█ ▀█▀ █▀▀ █▀█ █▀▀ ▄▀█ █▀▀ █ █▄░█ █▀▀ 
-- █ █░▀█ ░█░ ██▄ █▀▄ █▀░ █▀█ █▄▄ █ █░▀█ █▄█ 

-- These functions talk to Taskwarrior directly

--- Parse all tags
function task:parse_tags()
  local cmd = "task tag | head -n -2 | tail -n +4 | cut -f1 -d' ' "
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local tags = core.split('\r\n', stdout)
    self.tag_names = tags
    self:emit_signal("ready::tag_names")
  end)
end

--- Parse all pending tasks for a given tag and then sort them by project
-- (As far as I'm aware this is the only way to initially obtain the list of projects for a tag) 
function task:parse_tasks_for_tag(tag)
  local cmd = "task context none; task +'"..tag.. "' '(status:pending or status:waiting)' export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == EMPTY_JSON or stdout == "" then return end

    if not self.tags[tag] then self:add_new_tag(tag) end

    local json_arr = json.decode(stdout)

    -- Iterate through all pending tasks for tag and separate by project
    for i, v in ipairs(json_arr) do
      local pname = json_arr[i]["project"] or "Unsorted"
      if not self.tags[tag].projects[pname] then
        self:add_new_project(tag, pname)
      end
      table.insert(self.tags[tag].projects[pname].tasks, v)
    end

    self:sort_projects(tag)

    for i = 1, #self.tags[tag].project_names do
      local pname = self.tags[tag].project_names[i]
      self:parse_total_tasks_for_project(tag, pname)
      self:sort_task_descriptions(tag, pname)
    end

    self:emit_signal("ready::project_names", tag)
    -- self:emit_signal("ready::tasks", tag)
  end)
end

-- Used to update only one project (almost positively the focused project).
-- Called after the user modifies a task to reflect the user's changes.
function task:parse_tasks_for_project(tag, project)
  local cmd = "task +'"..tag.."' project:'"..project.."' '(status:pending or status:waiting)' export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    if stdout == EMPTY_JSON or stdout == "" then return end
    self.tags[tag].projects[project].tasks = json.decode(stdout)
    self:sort_task_descriptions(tag, project)
    self:emit_signal("ready::project_tasks", tag, project)
  end)
end

--- Get number of all tasks for project - completed and pending
-- The other function only returns pending tasks.
-- This information is required by project list and header.
function task:parse_total_tasks_for_project(tag, project)
  local unset_context = "task context none ; "
  local filters = "task +'"..tag.."' project:'"..project.."' "
  local status = " '(status:pending or status:completed or status:waiting)' "
  local cmd = unset_context .. filters .. status .. "count"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local total = tonumber(stdout) or 0
    self.tags[tag].projects[project].total = total

    local ready = self.tags[tag].projects_ready + 1
    self.tags[tag].projects_ready = ready
    if ready >= #self.tags[tag].project_names then
      self:emit_signal("ready::project_information", tag)
    end
  end)
end

--- Execute command given input and input type.
-- @param type    Type of input. See keybinds table in keybinds_tasklist.lua for complete list.
-- @param input   User input from awful.prompt
function task:execute_command(type, input)
  local ftag  = self.focused_tag
  local fproj = self.focused_project
  local ftask = self.focused_task
  local id = ftask["id"]
  local cmd

  if type == "add" then
    cmd = "task add proj:'"..fproj.."' tag:'"..ftag.."' '"..input.."'"
  end

  if type == "annotate" then
    cmd = "task " .. id .. " annotate " .. input
  end

  -- currently not used bc my taskwarrior hook fails when executing task undo
  -- if type == "undo" then
  --   if input == "y" or input == "Y" then
  --     cmd = "echo 'y' | task undo"
  --   else return end
  -- end

  if type == "delete" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task delete " .. id
    else return end
  end

  if type == "done" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task done " .. id
    else return end
  end

  if type == "search" then
    local tasks = self.tags[ftag].projects[fproj].tasks
    for i = 1, #tasks do
      if tasks[i]["description"] == input then
        self:emit_signal("tasklist::switch_index", i)
        return
      end
    end
  end

  if type == "start" then
    if ftask["start"] then
      cmd = "task " .. id .. " stop"
      time:emit_signal("set_tracking_inactive")
    else
      cmd = "task " .. id .. " start"
      time:emit_signal("set_tracking_active")
    end
  end

  if type == "reload" then
    if input == "y" or input == "Y" then
      self:reset()
      self.restore_required = true
    end
    return
  end

  -- Modal modify requests
  if type == "mod_due" then
    if input == "none" then input = '' end
    cmd = "task "..id.." mod due:'"..input.."'"
  elseif type == "mod_proj" then
    cmd = "task "..id.." mod proj:'"..input.."'"
  elseif type == "mod_tag" then
    cmd = "task "..id.." mod tag:'"..input.."'"
  elseif type == "mod_name" then
    cmd = "task "..id.." mod desc:'"..input.."'"
  elseif type == "mod_wait" then
    cmd = "task "..id.." mod wait:'"..input.."'"
  end

  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    self:selective_reload(type, input)
  end)
end


-- █▀▄ ▄▀█ ▀█▀ ▄▀█ █▄▄ ▄▀█ █▀ █▀▀ 
-- █▄▀ █▀█ ░█░ █▀█ █▄█ █▀█ ▄█ ██▄ 

-- Functions for handling already-parsed data

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


-- ▄▀█ █▀ █▀▄ █▀▀ ▄▀█ █▀ █▀▄ █▀▀ ▄▀█ █▀ █▀▄ 
-- █▀█ ▄█ █▄▀ █▀░ █▀█ ▄█ █▄▀ █▀░ █▀█ ▄█ █▄▀ 
-- idk what to call this section

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

function task:format_date(date, format)
  -- Taskwarrior returns due date as string
  -- Convert that to a lua timestamp
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = date:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })

  -- account for timezone (america/los_angeles: -8 hours)
  ts = ts - (8 * 60 * 60)

  format = format or '%A %B %d %Y'
  return os.date(format, ts)
end


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░    █▀ █▀▀ ▀█▀ █░█ █▀█ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄    ▄█ ██▄ ░█░ █▄█ █▀▀ 

function task:signal_setup()

  -- █▀█ █▀▀ ▄▀█ █▀▄ █▄█ 
  -- █▀▄ ██▄ █▀█ █▄▀ ░█░ 

  -- List of tags is ready
  self:connect_signal("ready::tag_names", function()
    if initializing() then
      inits_complete = inits_complete + 1
      self:set_focused_tag()
      self:parse_tasks_for_tag(self.focused_tag)
    end
    self:report_focused('ready::tag_names signal')
    self:emit_signal("taglist::update")
  end)

  -- List of projects for a tag is ready
  self:connect_signal("ready::project_names", function(_, tag)
    if initializing() then
      inits_complete = inits_complete + 1
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
    if initializing() then
      -- add 2 because this initializes the header and project list components
      inits_complete = inits_complete + 2
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

--------------------------------

function task:reset()
  -- self.tags = {}
  -- -- self.focused_tag      = nil
  -- -- self.focused_project  = nil
  -- self.focused_task     = nil
  self:parse_tags()
end

function task:new()
  self.show_waiting = false
  self.tags = {}
  self.focused_tag      = nil
  self.focused_project  = nil
  self.focused_task     = nil
  self:signal_setup()
  self:parse_tags()
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
