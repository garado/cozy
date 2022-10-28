
-- █▄▀ █▀▀ █▄█ █▀▀ █▀█ ▄▀█ █▄▄ █▄▄ █▀▀ █▀█ 
-- █░█ ██▄ ░█░ █▄█ █▀▄ █▀█ █▄█ █▄█ ██▄ █▀▄ 

-- Custom keys for managing tasks in the overview widget.

return function(task_obj)
  local function request(type)
    if not type then return end
    print("request::"..type)
    task_obj:emit_signal("tasks::input_request", type)
  end

  -- Default mode is normal mode
  -- Pressing 'm' puts you in modify mode
  local function modeswitch()
    print("modeswitch")
    request("modify")
    task_obj.in_modify_mode = true
  end

  local function handle_key(key)
    print("handle_key::"..key)
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
      ["/"] = "search",
    }

    local modify = {
      ["d"] = "mod_due",
      ["p"] = "mod_proj",
      ["t"] = "mod_tag",
      ["n"] = "mod_name",
      ["Escape"] = "mod_clear",
    }

    if task_obj.in_modify_mode then
      if modify[key] then
        request(modify[key])
      else
        request("mod_clear")
        request("mod_clear")
      end
      task_obj.in_modify_mode = false
    else
      if normal[key] then
        request(normal[key])
      end
    end
  end

  return {
    ["m"] = modeswitch, -- enter modify mode
    ["H"] = {["function"] = handle_key, ["args"] = "H"}, -- help menu
    ["a"] = {["function"] = handle_key, ["args"] = "a"}, -- add new task
    ["x"] = {["function"] = handle_key, ["args"] = "x"}, -- delete
    ["s"] = {["function"] = handle_key, ["args"] = "s"}, -- toggle start
    ["u"] = {["function"] = handle_key, ["args"] = "u"}, -- undo
    ["d"] = {["function"] = handle_key, ["args"] = "d"}, -- done, (modify) due date
    ["p"] = {["function"] = handle_key, ["args"] = "p"}, -- add new project, (modify) project
    ["t"] = {["function"] = handle_key, ["args"] = "t"}, -- add new tag, (modify) task
    ["n"] = {["function"] = handle_key, ["args"] = "n"}, -- next, (modify) taskname
    ["/"] = {["function"] = handle_key, ["args"] = "/"}, -- search
    ["Escape"] = {["function"] = handle_key, ["args"] = "Escape"}, -- (modify) clear
  }
end
