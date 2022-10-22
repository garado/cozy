
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 
-- A textbox used for adding and modifying tasks

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local colorize = require("helpers.ui").colorize_text
local remove_pango = require("helpers.dash").remove_pango
local dpi = xresources.apply_dpi
local gears = require("gears")
local gfs = require("gears.filesystem")

--- Adds formatting to prompt text.
-- @param text The text to promptify.
local function create_prompt(text)
  text = "<b>" .. text .. "</b>"
  return colorize(text, beautiful.fg)
end

-- Module-level variables
local searching = true

return function(task_obj)
  local prompt_textbox = wibox.widget({
    font = beautiful.font,
    widget = wibox.widget.textbox,
  })

  task_obj.dash_closed_during_input = false

  -- Support tab completion when searching through tabs
  local function search_callback(command_before_comp, cur_pos_before_comp, ncomp)
    local proj = task_obj.current_project
    local tasks = task_obj.projects[proj].tasks
    local searchtasks = {}

    -- Need to put all of the task descriptions into their own separate table
    -- Not the most optimal way to do this probably, but it is a way
    for i = 1, #tasks do
      table.insert(searchtasks, tasks[i]["description"])
    end

    return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, searchtasks)
  end

  -- Starts prompt to get user input
  local function task_input(type, prompt, text)
    local default_prompt = colorize("<b>"..type..": </b>", beautiful.fg)
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

  -- Emitted by keygrabber when a valid keybind is triggered.
  -- Change prompt depending on what action the user is performing,
  -- then call awful.prompt to get user input
  task_obj:connect_signal("tasks::input_request", function(_, type)
    print("prompt::caught input_request signal")
    local prompt, text

    -- Standard requests
    if type == "add" then
      prompt = colorize("<b>Add task: </b>", beautiful.fg)
    elseif type == "modify" then
      prompt = colorize("<b>Modify: </b>", beautiful.fg)
      prompt = prompt .. " (d) due date, (n) task name, (p) project, (t) tag"
      prompt_textbox:set_markup_silently(prompt)
      return
    elseif type == "delete" then
      prompt = create_prompt("Delete task? (y/n) ")
    elseif type == "done" then
      prompt = create_prompt("Mark as done? (y/n) ")
    elseif type == "start" then
      -- toggling start/stop is disabled for now
      require("naughty").notification {
        message = "Starting/stopping tasks not implemented yet :("
      }
      --local cmd
      --if task_obj.start then
      --  local cmd = "task start " .. task_obj.id
      --else
      --  local cmd = "task stop" .. task_obj.id
      --end
      --awful.spawn.with_shell(cmd)
    elseif type == "new_proj" then
      prompt = colorize("<b>Add project: </b>", beautiful.fg)
    elseif type == "new_tag" then
      prompt = colorize("<b>Add tag: </b>", beautiful.fg)
    elseif type == "help" then
      require("naughty").notification {
        message = "Help not implemented yet :("
      }
      return
    elseif type == "search" then
      prompt = colorize("<b>/</b>", beautiful.fg)

    -- Modal modify requests
    elseif type == "mod_due" then
      prompt = colorize("<b>Modify due date: </b>", beautiful.fg)
    elseif type == "mod_tag" then
      prompt = colorize("<b>Modify tag: </b>", beautiful.fg)
    elseif type == "mod_proj" then
      prompt = colorize("<b>Modify project: </b>", beautiful.fg)
    elseif type == "mod_name" then
      prompt = colorize("<b>Modify task name: </b>", beautiful.fg)
      text = remove_pango(task_obj.current_task)
    elseif type == "mod_clear" then
      prompt_textbox:set_markup_silently("")
      return
    end

    task_input(type, prompt, text)
  end)

  -- Emitted by awful.prompt when Enter/Return is pressed.
  -- Call taskwarrior command from user input
  task_obj:connect_signal("tasks::input_completed", function(_, type, input)
    local proj = task_obj.current_project
    local tag  = task_obj.current_tag
    local id   = task_obj.id
    local cmd

    -- Standard requests
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
      local proj = task_obj.current_project
      local tasks = task_obj.projects[proj].tasks
      for i = 1, #tasks do
        if tasks[i]["description"] == input then
          task_obj:emit_signal("tasks::switch_to_task_index", i)
          return
        end
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

    awful.spawn.easy_async_with_shell(cmd, function()
      print("prompt: emit project_modified")
      task_obj:emit_signal("tasks::project_modified", tag, proj, type)
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
