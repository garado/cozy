
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

  -- Change what the prompt and default prompt text look like depending
  -- on what action the user is performing
  task_obj:connect_signal("tasks::input_request", function(_, type)
    if      type == "add" then
      local prompt = colorize("<b>Add: </b>", beautiful.fg)
      task_input(type, prompt)
    elseif  type == "modify" then
      local prompt = colorize("<b>Modify: </b>", beautiful.fg)
      local text = remove_pango(task_obj.current_task)
      task_input(type, prompt, text)
    elseif  type == "delete" then
      local prompt = colorize("<b>Delete task? (y/n) </b>", beautiful.fg)
      task_input(type, prompt)
    elseif  type == "done" then
      local prompt = colorize("<b>Mark as done? (y/n) </b>", beautiful.fg)
      task_input(type, prompt)
    elseif  type == "start" then
      local cmd
      if task_obj.start then
        local cmd = "task start " .. task_obj.id
      else
        local cmd = "task stop" .. task_obj.id
      end
      --awful.spawn.with_shell(cmd)
    end
  end)

  -- Call taskwarrior command from user input
  task_obj:connect_signal("tasks::input_completed", function(_, type, input)
    local proj = task_obj.current_project
    local tag  = task_obj.current_tag
    local id   = task_obj.id

    local cmd
    if      type == "add" then
      cmd = "task add proj:'"..proj.."' tag:'"..tag.."' '"..input.."'"
    elseif  type == "modify" then
      cmd = "task "..id.." mod "..input
    elseif  type == "delete" then
      if input == "y" or input == "Y" then
        cmd = "echo 'y' | task delete " .. id
      end
    elseif  type == "done" then
      if input == "y" or input == "Y" then
        cmd = "echo 'y' | task done " .. id
      end
    end

    awful.spawn.easy_async_with_shell(cmd, function()
      print("prompt: emit project_modified")
      task_obj:emit_signal("tasks::project_modified", tag, proj, type)
    end)
  end)
  --task_obj:connect_signal("tasks::task_add_input_received", function(_, input)
  --  local proj = task_obj.current_project
  --  local tag  = task_obj.current_tag
  --  local cmd = "task add proj:'"..proj.."' tag:'"..tag.."' '"..input.."'"
  --  require("naughty").notification { message = cmd, timeout = 0}
  --  awful.spawn(cmd)
  --end)

  local widget = wibox.widget({
    textbox,
    margins = dpi(15),
    widget = wibox.container.margin,
  })

  return widget
end
