
-- █▄▀ █▀▀ █▄█ █▀▀ █▀█ ▄▀█ █▄▄ █▄▄ █▀▀ █▀█ 
-- █░█ ██▄ ░█░ █▄█ █▀▄ █▀█ █▄█ █▄█ ██▄ █▀▄ 
-- Custom keys for managing tasks in the overview widget.
-- super messy :/

return function(task_obj)
  local function request(type)
    if task_obj.wait_next_keypress then
      task_obj.wait_next_keypress = false
    else
      task_obj:emit_signal("tasks::input_request", type)
    end
  end

  local function modal()
    request("modify")
    task_obj.wait_next_keypress = true
  end

  local function handle_modal(key)
    local not_waiting = {
      ["d"] = request("done"),
      ["p"] = request("new_proj"),
      ["t"] = request("new_tag"),
    }

    local waiting = {
      ["d"] = request("mod_due"),
      ["p"] = request("mod_due"),
      ["t"] = request("mod_due"),
      ["n"] = request("mod_name"),
      ["Escape"] = request("mod_clear"),
    }

    if task_obj.wait_next_keypress then
      waiting[key]()
    else
      not_waiting[key]()
    end
  end

  return {
    ["a"] = {["function"] = request, ["args"] = "add"},     -- add new task
    ["x"] = {["function"] = request, ["args"] = "delete"},  -- delete
    ["s"] = {["function"] = request, ["args"] = "start"},   -- toggle start
    ["u"] = {["function"] = request, ["args"] = "undo"},    -- undo
    ["H"] = {["function"] = request, ["args"] = "help"},    -- help menu
    ["m"] = modal, -- modify
    ["d"] = {["function"] = handle_modal, ["args"] = "d"}, -- done, (modify) due date
    ["p"] = {["function"] = handle_modal, ["args"] = "p"}, -- add new project, (modify) project
    ["t"] = {["function"] = handle_modal, ["args"] = "t"}, -- add new tag, (modify) task
    ["n"] = {["function"] = handle_modal, ["args"] = "n"}, -- (modify) taskname
    ["Escape"] = {["function"] = handle_modal, ["args"] = "Escape"}, -- (modify) clear
  }
end
