
-- █▀█ ▄▀█ █▀█ █▀ █▀▀ █▀█ 
-- █▀▀ █▀█ █▀▄ ▄█ ██▄ █▀▄ 

-- Responsible for parsing JSON output of taskwarrior.
-- Also emits update signal to various widgets.

local awful = require("awful")
local json = require("modules.json")

return function(task_obj)
  task_obj:connect_signal("tasks::tag_selected", function(_, tag)
    local cmd = "task context none ; task tag:"..tag.." status:pending export rc.json.array=on"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      local empty_json = "[\n]\n"
      if stdout ~= empty_json and stdout ~= "" then
        local json_arr = json.decode(stdout)

        -- separate tasks by project
        local projects = {}
        for i, _ in ipairs(json_arr) do
          local due   = json_arr[i]["due"]
          local desc  = json_arr[i]["description"]
          local proj  = json_arr[i]["project"]

          local task = { desc, due }
          if not projects[proj] then projects[proj] = {} end
          table.insert(projects[proj], task)
        end

        task_obj.projects = projects
        task_obj:emit_signal("tasks::json_parsed")
      end
    end)
  end)
end
