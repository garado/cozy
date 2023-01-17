
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


-- █░█ █ 
-- █▄█ █ 

local prompt_textbox = wibox.widget({
  font = beautiful.base_small_font,
  widget = wibox.widget.textbox,
})

local prompt_textbox_colorized = wibox.container.background()
prompt_textbox_colorized:set_widget(prompt_textbox)
prompt_textbox_colorized:set_fg(beautiful.fg)


-- █▀▀ █▀█ █▀▄▀█ █▀█ █░░ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- █▄▄ █▄█ █░▀░█ █▀▀ █▄▄ ██▄ ░█░ █ █▄█ █░▀█ ▄█ 

local function desc_search_callback(command_before_comp, cur_pos_before_comp, ncomp)
  local t = task.focused_tag
  local p = task.focused_project
  local tasks = task.tags[t].projects[p].tasks

  -- Need to put all of the task descriptions into their own separate table
  -- Probably not the most optimal way to do this, but it is... a way
  local searchtasks = {}
  for i = 1, #tasks do
    searchtasks[#searchtasks+1] = tasks[i]["description"]
  end

  return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, searchtasks)
end

--- BUG this errors on tab completion when you have text written
local function project_search_callback(command_before_comp, cur_pos_before_comp, ncomp)
  local ftag = task.focused_tag
  local projects = task.tags[ftag].project_names
  return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, projects)
end

--- BUG this errors on tab completion when you have text written
local function tag_search_callback(command_before_comp, cur_pos_before_comp, ncomp)
  local tags = task:tag_names()
  return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, tags)
end

local function get_completion_callback(type)
  local ret = nil
  if type == "search" then
    ret = desc_search_callback
  elseif type == "mod_proj" then
    ret = project_search_callback
  elseif type == "mod_tag"  then
    ret = tag_search_callback
  end
  return ret
end

-------------------------

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function task_input(type, prompt, text)
  local comp_callback   = get_completion_callback(type)
  local default_prompt  = pango_bold(type..": ", beautiful.fg)

  awful.prompt.run {
    font         = beautiful.base_small_font,
    prompt       = prompt or default_prompt,
    text         = text or "",
    fg           = beautiful.fg,
    bg           = beautiful.task_prompt_textbg,
    shape        = gears.shape.rounded_rect,
    bg_cursor    = beautiful.main_accent,
    textbox      = prompt_textbox,
    exe_callback = function(input)
      if not input or #input == 0 then return end
      task:emit_signal("input::complete", type, input)
    end,
    completion_callback = comp_callback,
  }
end

--- Generates the prompt to display based on type of input requested,
-- then calls function to actually start the prompt
task:connect_signal("input::request", function(_, type)
  print("prompt::caught input_request signal")

  local prompt_options = {
    ["add"]       = "Add quest: ",
    ["modify"]    = "Modify: " .. "(d) due date, (n) quest name, (p) project, (t) tag",
    ["done"]      = "Complete quest? (y/n) ",
    ["delete"]    = "Abandon quest? (y/n) ",
    ["reload"]    = "Reload quests? (y/n) ",
    ["undo"]      = "",
    ["search"]    = "/",
    ["mod_proj"]  = "Modify project: ",
    ["mod_tag"]   = "Modify tag: ",
    ["mod_due"]   = "Modify due date: ",
    ["mod_name"]	= "Modify quest name: ",
  }

  local text_options = {
    ["mod_name"]  = task.focused_task["description"]
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

return wibox.widget({
  prompt_textbox_colorized,
  margins = dpi(15),
  widget = wibox.container.margin,
})
