
-- █▄▀ █▀▀ █▄█ █▀ 
-- █░█ ██▄ ░█░ ▄█ 

-- Custom keys for managing tasks in the tasklist widget.
-- Handles executing Taskwarrior commands.

local awful   = require("awful")
local task    = require("core.system.task")
local core    = require("helpers.core")

local function request(type)
  if not type then return end
  task:emit_signal("key::input_request", type)
end

local function modeswitch()
  request("modify")
  task.in_modify_mode = true
end

local function handle_key(key)
  local normal = {
    ["a"] = "add",
    ["s"] = "start",
    ["u"] = "undo",
    ["d"] = "done",
    ["x"] = "delete",
    ["p"] = "new_proj",
    ["t"] = "new_tag",
    ["n"] = "next",
    ["H"] = "help",
    ["R"] = "reload",
    ["/"] = "search",
  }

  local modify = {
    ["d"] = "mod_due",
    ["p"] = "mod_proj",
    ["t"] = "mod_tag",
    ["n"] = "mod_name",
    ["Escape"] = "mod_clear",
  }

  if task.in_modify_mode then
    if modify[key] then
      request(modify[key])
    else
      request("mod_clear")
    end
    task.in_modify_mode = false
  else
    if normal[key] then
      request(normal[key])
    end
  end
end

task:connect_signal("key::input_completed", function(_, type, input)
  local tag     = task:get_focused_tag()
  local project = task:get_focused_project()
  local _task   = task:get_focused_task()
  local id = _task["id"]
  local cmd

  if type == "add" then
    cmd = "task add proj:'"..project.."' tag:'"..tag.."' '"..input.."'"
  end

  if type == "delete" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task delete " .. id
    else return end
  elseif type == "done" then
    if input == "y" or input == "Y" then
      cmd = "echo 'y' | task done " .. id
    else return end
  elseif type == "search" then
    local tasks = task._private.tags[tag].projects[project].tasks
    for i = 1, #tasks do
      if tasks[i]["description"] == input then
        task:emit_signal("ui::switch_tasklist_index", i)
        return
      end
    end
  elseif type == "start" then
    if _task["start"] then
      cmd = "task " .. id .. " stop"
    else
      cmd = "task " .. id .. " start"
    end
  elseif type == "reload" then
    if input == "y" or input == "Y" then
      task:reset()
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

  -- Execute command
  awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr)
    -- Check for invalid date
    if string.find(stderr, "is not a valid date") then return end

    -- Stdout gives you new task id; need to store in local database
    -- Stdout looks like: Modifying task ### 'Task name'.
    local words = core.split(' ', stdout)
    local new_id = words[3]

    -- If nothing was modified, stdout looks like: Modified 0 tasks.
    if words[2] == "0" then return end

    local signal = "modified::" .. type
    task:emit_signal(signal, tag, project, input, new_id)
  end)
end)

return {
  ["m"] = modeswitch, -- enter modify mode
  -- ["H"] = {["function"] = handle_key, ["args"] = "H"}, -- help menu
  ["a"] = {["function"] = handle_key, ["args"] = "a"}, -- add new task
  ["x"] = {["function"] = handle_key, ["args"] = "x"}, -- delete
  ["s"] = {["function"] = handle_key, ["args"] = "s"}, -- toggle start
  ["u"] = {["function"] = handle_key, ["args"] = "u"}, -- undo
  ["d"] = {["function"] = handle_key, ["args"] = "d"}, -- done; (modify) due date
  ["p"] = {["function"] = handle_key, ["args"] = "p"}, -- add new project; (modify) project
  ["t"] = {["function"] = handle_key, ["args"] = "t"}, -- add new tag; (modify) task
  ["n"] = {["function"] = handle_key, ["args"] = "n"}, -- next; (modify) taskname
  ["R"] = {["function"] = handle_key, ["args"] = "R"}, -- restart + reload all tasks
  ["/"] = {["function"] = handle_key, ["args"] = "/"}, -- search
  ["Escape"] = {["function"] = handle_key, ["args"] = "Escape"}, -- (modify) clear
}
