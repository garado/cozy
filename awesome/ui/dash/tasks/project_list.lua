
-- █▀█ █▀█ █▀█ ░░█ █▀▀ █▀▀ ▀█▀ █▀ 
-- █▀▀ █▀▄ █▄█ █▄█ ██▄ █▄▄ ░█░ ▄█ 
-- Returns a table of project names associated with a given tag.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local widgets = require("ui.widgets")

return function(tag)
  local projects = {}
  local function parse_taskw_projects(stdout)
    for line in string.gmatch(stdout, "[^\r\n]+") do
      -- the task count is the string of numbers at end of line
      -- so to get the task count, remove everything except for that
      local count = string.gsub(line, "[^%d+$]", "")

      -- to get project name, remove the task count
      local name = string.gsub(line, "%s+%d+$", "")

      local project = {
        ["name"]  = name,
        ["count"] = count,
      }
      table.insert(projects, project)
    end

    -- the first 2 lines are headers - discard
    table.remove(projects, 1)
    table.remove(projects, 1)

    -- last line isn't a project either
    table.remove(projects)
  end

  local cmd = "task context none ; task tag:"..tag.." projects"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    parse_taskw_projects(stdout)
  end)
  return projects
end
