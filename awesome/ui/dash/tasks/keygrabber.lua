
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

  -- █▀▄▀█ █▀█ █▀▄ ▄▀█ █░░    █▀▄▀█ █▀█ █▀▄ █ █▀▀ █▄█ 
  -- █░▀░█ █▄█ █▄▀ █▀█ █▄▄    █░▀░█ █▄█ █▄▀ █ █▀░ ░█░ 
  local function modal()
    request("modify")
    task_obj.wait_next_keypress = true
  end

  local function d()
    if not task_obj.wait_next_keypress then
      request("done")
    else
      task_obj.wait_next_keypress = false
      request("mod_due")
    end
  end

  local function p()
    if not task_obj.wait_next_keypress then
      request("new_proj")
    else
      task_obj.wait_next_keypress = false
      request("mod_proj")
    end
  end

  local function t()
    if not task_obj.wait_next_keypress then
      request("new_tag")
    else
      task_obj.wait_next_keypress = false
      request("mod_tag")
    end
  end

  local function n()
    if task_obj.wait_next_keypress then
      task_obj.wait_next_keypress = false
      request("mod_name")
    end
  end

  local function esc()
    request("mod_clear")
  end

  -- end modal modify
  ------------------------------------------

  local function a() request("add")      end
  local function x() request("delete")   end
  local function s() request("start")    end
  local function u() request("undo")     end
  local function m() modal()             end
  local function h_cap() request("help") end

  return {
    ["a"] = a, -- add new task
    ["m"] = m, -- modify
    ["d"] = d, -- done, (modify) due date
    ["x"] = x, -- delete
    ["s"] = s, -- toggle start
    ["u"] = u, -- undo
    ["p"] = p, -- add new project, (modify) project
    ["t"] = t, -- add new tag, (modify) task
    ["n"] = n, -- (modify) taskname
    ["Escape"] = esc,
    ["H"] = h_cap, -- help menu
  }
end
