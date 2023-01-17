
-- ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█ 
-- ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄ 

-- For interfacing with Taskwarrior.

-- SIGNALS            EMITTED WHEN
-- --------------     -----------------
-- ready::tags        Tags have been parsed
-- ready::all_projects    Projects for a given tag have been parsed
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
  -- # projects{} : table of all active projects associated with tag, indexed by project name
    -- # tasks{}  : table of all active tasks in project, indexed numerically

-- DATA FLOW (incomplete)
--                
--    STARTUP     ready:: ┌────────────┐   ready::
--  ┌────────────┐ tags   │parse_tasks_│    tasks
--  │parse_tags()│───┬──► │ for_tags() │──────────────────►
--  └────────────┘   ▼    └────────────┘   ready::
--               UI update:              project_list
--                  tags

local gobject = require("gears.object")
local gtable  = require("gears.table")
local awful   = require("awful")
local json    = require("modules.json")
local core    = require("helpers.core")
local gears   = require("gears")
local config  = require("config")
local time    = require("core.system.time")

local debug   = require("core.debug")
debug:off()

local task = {}
local instance = nil

local EMPTY_JSON = "[\n]\n"

--------------------------------

-- For debugging
function task:report_focused(src)
  local curtag = self.focused_tag or "NIL"
  local curproj = self.focused_project or "NIL"
  src = (src and ' from ' .. src) or ""
  debug:print("\tcore::task: focused tag is "..curtag..", focused proj is "..curproj .. src)
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
    self:emit_signal("ready::tags")
  end)
end

function task:sort_projects(tag)
  table.sort(self.tags[tag].project_names, function(a, b)
    return a < b
  end)
end

--- Parse all pending tasks for a given tag and then sort them by project
-- (As far as I'm aware this is the only way to initially obtain the list of projects for a tag) 
function task:parse_tasks_for_tag(tag)
  local cmd = "task context none; task tag:"..tag.. " status:pending export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    if stdout == EMPTY_JSON or stdout == "" then return end

    local json_arr = json.decode(stdout)

    -- Iterate through all pending tasks for tag and separate by project
    local projects = {}
    local project_names = {}
    for i, v in ipairs(json_arr) do
      local project_name = json_arr[i]["project"] or "Unsorted"
      if not projects[project_name] then
        projects[project_name] = {}
        projects[project_name].tasks = {}
        projects[project_name].total = 0
        project_names[#project_names+1] = project_name
      end
      table.insert(projects[project_name].tasks, v)
    end

    -- Store final data in task object
    self.tags[tag] = {}
    self.tags[tag].projects = projects
    self.tags[tag].projects_ready = 0
    self.tags[tag].project_names = project_names

    self:sort_projects(tag)

    for i = 1, #self.tags[tag].project_names do
      local pname = self.tags[tag].project_names[i]
      self:parse_total_tasks_for_project(tag, pname)
      self:sort_task_descriptions(tag, pname)
    end

    self:emit_signal("ready::project_list", tag)
    -- self:emit_signal("ready::tasks", tag)
  end)
end

-- Used to update only one project (almost positively the focused project).
-- Called after the user modifies a task to reflect the user's changes.
function task:parse_tasks_for_project(tag, project)
  local cmd = "task tag:'"..tag.."' project:'"..project.."' status:pending export rc.json.array=on"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
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
  local filters = "task tag:'"..tag.."' project:'"..project.."' "
  local status = " '(status:pending or status:completed)' "
  local cmd = unset_context .. filters .. status .. "count"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local total = tonumber(stdout) or 0
    self.tags[tag].projects[project].total = total

    local ready = self.tags[tag].projects_ready + 1
    self.tags[tag].projects_ready = ready
    if ready == #self.tags[tag].project_names then
      self:emit_signal("ready::all_projects", tag)
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
    cmd = "task "..id.." mod due:'"..input.."'"
  elseif type == "mod_proj" then
    cmd = "task "..id.." mod proj:'"..input.."'"
  elseif type == "mod_tag" then
    cmd = "task "..id.." mod tag:'"..input.."'"
  elseif type == "mod_name" then
    cmd = "task "..id.." mod desc:'"..input.."'"
  end

  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    print(cmd)
    print(stdout)
    print(stderr)

    local ft  = self.focused_tag
    local fp  = self.focused_project
    local ntasks = #self.tags[ft].projects[fp].tasks
    local nproj  = #self.tags[ft].project_names
    local pnames = self.tags[ft].project_names

    -- Check for invalid date
    -- TODO tell the user and awful.prompt persist
    if string.find(stderr, "is not a valid date") then
      print('Invalid date')
    end

    self.restore_required = true

    -- Reflect changes by selectively reloading components 
    local case1 = type == "mod_proj" and ntasks > 1  and nproj > 1
    local case2 = (type == "mod_proj" or type == "done" or type == "delete") and ntasks == 1 and nproj > 1
    local case3 = (type == "mod_proj" or type == "done" or type == "delete") and ntasks == 1 and nproj == 1
    local case4 = type == "mod_tag" and ntasks == 1 and nproj > 1
    local case5 = type == "mod_tag" and ntasks == 1 and nproj == 1
    local casex = not case1 and not case2 and not case3

    print('Case 1 '..(case1 and 'true' or 'false'))
    print('Case 2 '..(case2 and 'true' or 'false'))
    print('Case 3 '..(case3 and 'true' or 'false'))
    print('Case x '..(casex and 'true' or 'false'))

    -- Case 1: Modifying two projects, focused tag/focused project remain
    -- Reload both projects
    if case1 then
      -- Usually ready == #projects, but if you're adding a new project, 
      -- then ready == #projects-1
      local readymod = 2

      -- Initialize new project if it doesn't exist already
      if self.tags[ft].projects[input] == nil then
        self.tags[ft].projects[input] = {}
        self.tags[ft].projects[input].tasks = {}
        self.tags[ft].projects[input].total = 0
        table.insert(self.tags[ft].project_names, input)
        self:sort_projects(ft)
        readymod = 1
      end

      self.tags[ft].projects_ready = self.tags[ft].projects_ready - readymod
      self:parse_tasks_for_project(ft, fproj)
      self:parse_tasks_for_project(ft, input)
    end

    -- Case 2: Focused project completes, focused tag remains
    -- Change focused project, reload new focused project
    if case2 then
      -- Remove completed project from project list
      self.tags[ft].projects[fp] = nil
      for i = 1, #pnames do
        if pnames[i] == fp then
          table.remove(pnames, i)
          break
        end
      end

      -- Determine new focused project
      self.focused_project = type == "mod_proj" and input or pnames[1]

      self.tags[ft].projects_ready = self.tags[ft].projects_ready - 2
      self:parse_tasks_for_project(self.focused_tag, self.focused_project)
    end

    -- Case 3: Focused project completes, causing focused tag to complete
    -- Reload tag list, reload project list, switch focused tag
    -- TODO: account for if the completed tag is the last tag remaining
    if case3 then
      -- Remove completed tag
      self.tags[ft] = nil
      for i = 1, #self.tag_names do
        if self.tag_names[i] == ft then
          table.remove(self.tag_names, i)
          break
        end
      end

      -- Set new focused tag and project
      self.focused_tag = self.tag_names[1]
      self.focused_project = nil
      self:set_focused_project(self.focused_tag)

      self:emit_signal("taglist::update")
      self:emit_signal("projects::update", self.focused_tag, self.focused_project)
      self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
      self:emit_signal("header::update", self.focused_tag, self.focused_project)
    end

    -- Init new tag if it does not already exist
    if type == "mod_tag" and not self.tags[input] then
      if not self.tags[input] then
        self.tag_names[#self.tag_names+1] = input
        self.tags[input] = {}
        self:parse_tasks_for_tag(input)
      end
    end

    -- Case 4: mod tag causes project to complete, but not tag
    -- Set new fproj, reload plist
    if case4 then
      -- Remove project from tag
      self.tags[ft].projects[fp] = nil
      for i = 1, pnames do
        if pnames[i] == fp then
          table.remove(pnames, i)
          break
        end
      end

      self.focused_project = nil
      self:set_focused_project(self.focused_tag)

      self:emit_signal("projects::update", self.focused_tag, self.focused_project)
      self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
      self:emit_signal("header::update", self.focused_tag, self.focused_project)
    end

    -- Case 5: mod tag causes project and tag to complete
    if case5 then
      -- Remove old tag
      self.tags[ft] = nil
      for i = 1, #self.tag_names do
        if self.tag_names[i] == ft then
          table.remove(self.tag_names, i)
          break
        end
      end

      -- Set new focused tag/project
      self.focused_tag = input
      self.focused_project = nil
      self:set_focused_project(self.focused_tag)

      --self:emit_signal("projects::update", self.focused_tag, self.focused_project)
      --self:emit_signal("tasklist::update", self.focused_tag, self.focused_project)
      --self:emit_signal("header::update", self.focused_tag, self.focused_project)
    end

    -- Case X: Everything else (modifying one project, ft+fp remain)
    if casex then
      self:parse_tasks_for_project(ftag, fproj)
    end
  end)
end


-- ▄▀█ █▀ █▀▄ █▀▀ ▄▀█ █▀ █▀▄ █▀▀ ▄▀█ █▀ █▀▄ 
-- █▀█ ▄█ █▄▀ █▀░ █▀█ ▄█ █▄▀ █▀░ █▀█ ▄█ █▄▀ 

-- Manipulation of already parsed data

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


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░    █▀ █▀▀ ▀█▀ █░█ █▀█ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄    ▄█ ██▄ ░█░ █▄█ █▀▀ 

function task:signal_setup()
  -- READY -------------------------
  -- List of tags is ready
  self:connect_signal("ready::tags", function()
    self:set_focused_tag()
    self:parse_tasks_for_tag(self.focused_tag)
    -- self:report_focused('ready::tags signal')
    self:emit_signal("taglist::update")
  end)

  -- List of projects for a tag is ready
  self:connect_signal("ready::project_list", function(_, tag)
    self.focused_project = nil
    self:set_focused_project(tag, nil)
    -- self:report_focused('readY::projectlist signal')
    self:emit_signal("tasklist::update", tag, self.focused_project)
  end)

  -- All project information is ready (project list and total tasks per project)
  self:connect_signal("ready::all_projects", function(_, tag)
    -- self:report_focused('readty::projects signal')
    self:emit_signal("projects::update", tag)
    self:emit_signal("header::update", tag, self.focused_project)
  end)

  -- TODO refactor and clarify i barely know wtf is going on
  self:connect_signal("ready::project_tasks", function(_, tag, project)
    if project == self.focused_project then
      self:emit_signal("tasklist::update", tag, project)
    end
    self:parse_total_tasks_for_project(tag, project)
  end)

  -- SELECTED -------------------------
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
    -- self:report_focused()
    self:emit_signal("header::update", self.focused_tag, self.focused_project)
    self:emit_signal("tasklist::update", self.focused_tag, project)
  end)

  -- INPUT -------------------------
  self:connect_signal("input::complete", self.execute_command)
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
