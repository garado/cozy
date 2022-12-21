
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

-- A text field to get user input for adding and modifying tasks.

local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local dpi   = xresources.apply_dpi
local pango_bold  = require("helpers.core").pango_bold

local task = require("core.system.task")

-------------------------

local function desc_search_callback(command_before_comp, cur_pos_before_comp, ncomp)
  local tasks = task:get_pending_tasks()
  local searchtasks = {}

  -- Need to put all of the task descriptions into their own separate table
  -- Probably not the most optimal way to do this, but it is... a way
  for i = 1, #tasks do
    table.insert(searchtasks, tasks[i]["description"])
  end

  return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, searchtasks)
end

-------------------------

local prompt_textbox = wibox.widget({
  font = beautiful.font,
  widget = wibox.widget.textbox,
})

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function task_input(type, prompt, text)
  local default_prompt = pango_bold(type..": ", beautiful.fg)
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
      task:emit_signal("key::input_completed", type, input)
    end,
    completion_callback = desc_search_callback,
  }
end

task:connect_signal("key::input_request", function(_, type)
  print("prompt::caught input_request signal")

  local prompt_options = {
    ["add"]       = "Add task: ",
    ["modify"]    = "Modify: " .. " (d) due date, (n) task name, (p) project, (t) tag",
    ["done"]      = "Mark as done? (y/n) ",
    ["delete"]    = "Delete task? (y/n) ",
    ["undo"]      = "",
    ["search"]    = "/",
    ["mod_proj"]  = "Modify project: ",
    ["mod_tag"]   = "Modify tag: ",
    ["mod_due"]   = "Modify due date: ",
    ["mod_name"]	= "Modify task name: ",
  }

  local text_options = {
    ["mod_name"]  = task:get_focused_task_desc(),
  }

  local prompt  = (prompt_options[type] and pango_bold(prompt_options[type], beautiful.fg)) or ""
  local text    = text_options[type] or ""

  -- Modify and Start take no textbox input - they just execute
  if type == "modify" then
    prompt_textbox:set_markup_silently(prompt)
    return
  end

  if type == "start" then
    prompt_textbox:set_markup_silently(prompt)
    task:emit_signal("key::input_completed", "start", "")
    return
  end

  task_input(type, prompt, text)
end)

-------------------------

local prompt_textbox_colorized = wibox.container.background()
prompt_textbox_colorized:set_widget(prompt_textbox)
prompt_textbox_colorized:set_fg(beautiful.fg)

return wibox.widget({
  prompt_textbox_colorized,
  margins = dpi(15),
  widget = wibox.container.margin,
})
