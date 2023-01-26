
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

local task     = {}
local instance = nil

-- For debugging
function task:report_focused(src)
  local curtag  = self.focused_tag or "NIL"
  local curproj = self.focused_project or "NIL"
  src = (src and ' from ' .. src) or ""
end

-- Functions that talk to Taskwarrior directly
require("core.system.task.interface")(task)

-- Functions for handling already-parsed data
require("core.system.task.database")(task)

-- Misc helper functions
require("core.system.task.misc")(task)

-- Set up signals
require("core.system.task.signals")(task)

function task:reset()
  self.inits_complete = 0
  self:parse_tags()
end

function task:new()
  self.inits_complete = 0
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
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
