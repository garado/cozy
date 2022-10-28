
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 
-- A textbox used for adding and modifying tasks.

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local colorize = require("helpers.ui").colorize_text
local remove_pango = require("helpers.dash").remove_pango
local dpi = xresources.apply_dpi
local gears = require("gears")

return function(task_obj)

  -- █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
  -- █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 
  --- Adds pango formatting to prompt text.
  -- @param text The text to promptify.
  local function promptify(text)
    text = "<b>" .. text .. "</b>"
    return colorize(text, beautiful.fg)
  end

  --- Reload components only when necessary.
  -- @param type The type of action being performed.
  -- @param input The user input.
  local function send_reload_signal(type, input)
    -- Reload tag list
    if type == "mod_tag" then
      task_obj:emit_signal("tasks::reload_tag_list")
    end

    -- Reload entire project list
    local project_added
    local project_removed
    if type == "mod_proj" then
      task_obj:emit_signal("tasks::reload_project_list_all")
    end

    -- Reload specific projects in project list
    -- if type == "mod_proj" then
    --   task_obj:emit_signal("tasks::reload_project_list_entry")
    -- end

    -- Reload overview task list
    if type == "" then
      task_obj:emit_signal("tasks::reload_task_list")
    end

    -- Reload overview header
    if type == "add" then
      task_obj:emit_signal("tasks::reload_overview_header")
    end

    -- Reload stats
    if type == "mod_proj" or type == "mod_tag" then
      task_obj:emit_signal("tasks::reload_stats")
    end
  end

  --- When the user modifies the tasklist, sometimes the currently selected task should
  -- change. For example, when adding a task, the selection should move to the newly-
  -- added task. This function handles these cases.
  -- @param type The action type.
  local function set_selected_task(type)
    local proj = task_obj.current_project
    local tasks = task_obj.projects[proj].tasks

    local newest = #tasks + 1
    local current = task_obj.current_task_index
    local prev = (current > 1 and current - 1) or 1

    local indices = {
      ["add"]       = newest,
      ["start"]     = current,
      ["mod_due"]   = current,
      ["mod_name"]	= current,
      ["done"]      = prev,
      ["delete"]    = prev,
      ["undo"]      = 1,
      ["mod_proj"]  = 1,
      ["mod_tag"]   = 1,
    }

    -- Default to first task
    task_obj.switch_index = true
    task_obj.index_to_switch = 1

    if indices[type] then
      task_obj.index_to_switch = indices[type]
    end
  end

  --- Support tab completion when searching through tabs.
  -- @params I don't really understand them tbh.
  local function search_callback(command_before_comp, cur_pos_before_comp, ncomp)
    local proj = task_obj.current_project
    local tasks = task_obj.projects[proj].tasks
    local searchtasks = {}

    -- Need to put all of the task descriptions into their own separate table
    -- Not the most optimal way to do this probably, but it is... a way
    for i = 1, #tasks do
      table.insert(searchtasks, tasks[i]["description"])
    end

    return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, searchtasks)
  end

  --- In the future I will have different completion options based on what exactly the
  -- user is trying to do, e.g. when searching through tasks, have a completion table full of tasks;
  -- when modifying tag, have a completion table full of the tag names. This skeleton is a reminder 
  -- to myself to implement that later.
  local function set_completion()
    -- local projects = {}
    --for k, _ in ipairs(task_obj.projects) do
    --  table.insert(projects, k)
    --end
  end

  -- ▀█▀ █░█ █▀▀    █▀▀ █▀█ █▀█ █▀▄    █▀ ▀█▀ █░█ █▀▀ █▀▀ 
  -- ░█░ █▀█ ██▄    █▄█ █▄█ █▄█ █▄▀    ▄█ ░█░ █▄█ █▀░ █▀░ 
  local prompt_textbox = wibox.widget({
    font = beautiful.font,
    widget = wibox.widget.textbox,
  })

  --- Starts prompt to get user input.
  -- @param type The action type.
  -- @param prompt The prompt to display.
  -- @param text The initial textbox text.
  local function task_input(type, prompt, text)
    local default_prompt = promptify(type..": ")
    awful.prompt.run {
      prompt       = prompt or default_prompt,
      text         = text or "",
      fg           = beautiful.fg,
      bg           = beautiful.task_prompt_textbg,
      shape        = gears.shape.rounded_rect,
      bg_cursor    = beautiful.main_accent,
      textbox      = prompt_textbox,
      exe_callback = function(input)
        if not input or #input == 0 then return end
        task_obj:emit_signal("tasks::input_completed", type, input)
      end,
      completion_callback = search_callback,
    }
  end

  --- Change prompt depending on what action the user is performing,
  -- then call awful.prompt to get user input.
  -- Emitted by keygrabber when a valid keybind is triggered.
  task_obj:connect_signal("tasks::input_request", function(_, type)
    print("prompt::caught input_request signal")

    local prompt_options = {
      ["add"]       = promptify("Add task: "),
      ["modify"]    = promptify("Modify: ") .. " (d) due date, (n) task name, (p) project, (t) tag",
      ["done"]      = promptify("Mark as done? (y/n) "),
      ["delete"]    = promptify("Delete task? (y/n) "),
      ["undo"]      = "",
      ["search"]    = promptify("/"),
      ["mod_proj"]  = promptify("Modify project: "),
      ["mod_tag"]   = promptify("Modify tag: "),
      ["mod_due"]   = promptify("Modify due date: "),
      ["mod_name"]	= promptify("Modify task name: "),
    }

    local text_options = {
      ["mod_name"]  = remove_pango(task_obj.current_task),
    }

    local prompt  = prompt_options[type] or ""
    local text    = text_options[type] or ""

    -- Modify and Start take no textbox input - they just execute
    if type == "modify" then
      prompt_textbox:set_markup_silently(prompt)
      return
    end

    if type == "start" then
      prompt_textbox:set_markup_silently(prompt)
      task_obj:emit_signal("tasks::input_completed", "start", "")
      return
    end

    task_input(type, prompt, text)
  end)

  --- Call Taskwarrior command based on user input.
  -- Emitted by the awful.prompt above when Enter/Return is pressed.
  task_obj:connect_signal("tasks::input_completed", function(_, type, input)
    local proj = task_obj.current_project
    local tag  = task_obj.current_tag
    local id   = task_obj.current_id
    local idx  = task_obj.current_task_index
    local task = task_obj.projects[proj].tasks[idx]
    local cmd

    if      type == "add" then
      cmd = "task add proj:'"..proj.."' tag:'"..tag.."' '"..input.."'"
    elseif  type == "delete" then
      if input == "y" or input == "Y" then
        cmd = "echo 'y' | task delete " .. id
      end
    elseif  type == "done" then
      if input == "y" or input == "Y" then
        cmd = "echo 'y' | task done " .. id
      end
    elseif  type == "search" then
      local tasks = task_obj.projects[proj].tasks
      for i = 1, #tasks do
        if tasks[i]["description"] == input then
          task_obj:emit_signal("tasks::switch_to_task_index", i)
          return
        end
      end
    elseif type == "start" then
      if task["start"] then
        cmd = "task " .. id .. " stop"
      else
        cmd = "task " .. id .. " start"
      end
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
    awful.spawn.easy_async_with_shell(cmd, function()
      print("prompt: emit project_modified")
      task_obj:emit_signal("tasks::project_modified", tag, proj, type)
      set_selected_task(type)
    end)
  end)

  local prompt_textbox_colorized = wibox.container.background()
  prompt_textbox_colorized:set_widget(prompt_textbox)
  prompt_textbox_colorized:set_fg(beautiful.fg)

  return wibox.widget({
    prompt_textbox_colorized,
    margins = dpi(15),
    widget = wibox.container.margin,
  })
end
