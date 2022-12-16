
-- █▀█ ▄▀█ █▀█ █▀ █▀▀ █▀█ 
-- █▀▀ █▀█ █▀▄ ▄█ ██▄ █▀▄ 

-- Responsible for parsing JSON output of taskwarrior.
-- Also emits update signal to various widgets.

local awful = require("awful")
local json = require("modules.json")

return function(task_obj)
  -- Parse all tasks associated with tag on tag selection
  task_obj:connect_signal("tasks::tag_selected", function(_, tag)
    local cmd = "task context none ; task tag:"..tag.." status:pending export rc.json.array=on"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local empty_json = "[\n]\n"
      if stdout ~= empty_json and stdout ~= "" then
        local json_arr = json.decode(stdout)

        -- separate tasks by project
        local projects = {}
        for i, v in ipairs(json_arr) do
          local proj = json_arr[i]["project"] or "No project"
          if not projects[proj] then
            projects[proj] = {}
            projects[proj].total = 0
            projects[proj].tasks = {}
          end
          table.insert(projects[proj].tasks, v)
        end

        task_obj.projects = projects
        task_obj:emit_signal("tasks::tag_json_parsed")
      end
    end)
  end)

  -- Parse all tasks associated with project on project update 
  -- Emitted by Taskwarrior hook and after receiving input from prompt
  task_obj:connect_signal("tasks::project_modified", function(_, tag, project)
    local cmd = "task context none ; task tag:"..tag.." proj:'"..project.."' status:pending export rc.json.array=on"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local empty_json = "[\n]\n"
      if stdout ~= empty_json and stdout ~= "" then
        local json_arr = json.decode(stdout)

        -- separate tasks by project
        local new_project = {
          total = 0,
          tasks = {},
        }
        for _, v in ipairs(json_arr) do
          table.insert(new_project.tasks, v)
        end

        task_obj.projects[project] = new_project
        task_obj:emit_signal("tasks::project_json_parsed", tag, project)
      end
    end)
  end)
end
