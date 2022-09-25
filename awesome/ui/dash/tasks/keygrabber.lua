
-- █▄▀ █▀▀ █▄█ █▀▀ █▀█ ▄▀█ █▄▄ █▄▄ █▀▀ █▀█ 
-- █░█ ██▄ ░█░ █▄█ █▀▄ █▀█ █▄█ █▄█ ██▄ █▀▄ 
-- Custom keys for managing tasks in the overview widget.

return function(task_obj)
  local function request(type)
    task_obj:emit_signal("tasks::input_request", type)
  end

  local function add()    request("add")    end
  local function modify() request("modify") end
  local function delete() request("delete") end
  local function done()   request("done")   end
  local function start()  request("start")  end
  local function undo()   request("undo")   end

  return {
    ["a"] = add,
    ["m"] = modify,
    ["d"] = done,
    ["x"] = delete,
    ["s"] = start,
    ["u"] = undo,
  }
end
