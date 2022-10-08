
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

return function(task_obj)
  local prompt_textbox = wibox.widget({
    font = beautiful.font,
    widget = wibox.widget.textbox,
  })

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
      end
    }
  end

  -- Emitted by keygrabber when a valid keybind is triggered
  -- Change prompt depending on what action the user is performing,
  -- then call awful.prompt to get user input
  task_obj:connect_signal("tasks::input_request", function(_, type)
    local prompt

    -- Standard requests
    if type == "add" then
      prompt = colorize("<b>Add task: </b>", beautiful.fg)
    elseif type == "modify" then
      prompt = colorize("<b>Modify: </b>", beautiful.fg)
      prompt = prompt .. " (d) due date, (n) task name, (p) project, (t) tag"
      prompt_textbox:set_markup_silently(prompt)
      return
    elseif type == "delete" then
      prompt = colorize("<b>Delete task? (y/n) </b>", beautiful.fg)
    elseif type == "done" then
      prompt = colorize("<b>Mark as done? (y/n) </b>", beautiful.fg)
    elseif type == "start" then
      -- toggling start/stop is disabled for now
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

    -- Modal modify requests
    elseif type == "mod_due" then
      prompt = colorize("<b>Modify due date: </b>", beautiful.fg)
    elseif type == "mod_tag" then
      prompt = colorize("<b>Modify tag: </b>", beautiful.fg)
    elseif type == "mod_proj" then
      prompt = colorize("<b>Modify project: </b>", beautiful.fg)
    elseif type == "mod_name" then
      prompt = colorize("<b>Modify task name: </b>", beautiful.fg)
    elseif type == "mod_clear" then
      prompt_textbox:set_markup_silently("")
      return
    end

    task_input(type, prompt)
  end)

  -- Emitted by awful.prompt when Enter/Return is pressed
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

  return wibox.widget({
    prompt_textbox,
    margins = dpi(15),
    widget = wibox.container.margin,
  })
end
