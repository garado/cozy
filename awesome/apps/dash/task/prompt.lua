
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

-- A text field to get user input for adding and modifying tasks.

local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local core  = require("helpers.core")

local task = require("core.system.task")


-- █░█ █ 
-- █▄█ █ 

local prompt_textbox = wibox.widget({
  font   = beautiful.font_reg_s,
  widget = wibox.widget.textbox,
})

local prompt_textbox_colorized = wibox.container.background()
prompt_textbox_colorized:set_widget(prompt_textbox)
prompt_textbox_colorized:set_fg(beautiful.fg_0)


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
  local default_prompt  = core.pango_bold(type..": ", beautiful.fg_0)

  awful.prompt.run {
    font         = beautiful.font_reg_s,
    prompt       = prompt or default_prompt,
    text         = text or "",
    fg           = beautiful.fg_0,
    bg           = beautiful.task_prompt_textbg,
    shape        = gears.shape.rounded_rect,
    bg_cursor    = beautiful.primary_0,
    textbox      = prompt_textbox,
    exe_callback = function(input)
      if not input or #input == 0 then
        task:emit_signal("input::cancelled")
        return
      end
      task:emit_signal("input::complete", type, input)
    end,
    completion_callback = comp_callback,
  }
end

--- Generates the prompt to display based on type of input requested,
-- then calls function to actually start the prompt
task:connect_signal("input::request", function(_, type)
  -- print("prompt::caught input_request signal")

  local prompt_options = {
    ["add"]       = "Add quest: ",
    ["annotate"]  = "Annotate: ",
    ["modify"]    = "Modify (d)ue, (n)ame, (p)roject, (t)ag, (w)ait, (L)ink: ",
    ["done"]      = "Complete quest? (y/n) ",
    ["open"]      = "Open link? (y/n) ",
    ["delete"]    = "Abandon quest? (y/n) ",
    ["reload"]    = "Reload quests? (y/n) ",
    ["undo"]      = "Undo? This is not reversible! (y/n)",
    ["search"]    = "/",
    ["mod_proj"]  = "Modify project: ",
    ["mod_tag"]   = "Modify tag: ",
    ["mod_due"]   = "Modify due date: ",
    ["mod_name"]	= "Modify quest name: ",
    ["mod_wait"]  = "Modify wait date: ",
    ["mod_link"]  = "Modify link: ",
  }

  local text_options = {
    ["mod_name"]  = task.focused_task["description"]
  }

  local prompt  = (prompt_options[type] and core.pango_bold(prompt_options[type], beautiful.fg_0)) or ""
  local text    = text_options[type] or ""

  -- Modify and Start take no textbox input - they just execute
  if type == "modify" then
    prompt_textbox:set_markup_silently(prompt)
    return
  end

  if type == "start" then
    prompt_textbox:set_markup_silently(prompt)
    task:emit_signal("input::complete", "start", "")
    return
  end

  -- Just clear the prompt
  if type == "mod_clear" then
    prompt_textbox:set_markup_silently("")
    return
  end

  task_input(type, prompt, text)
end)

return wibox.widget({
  prompt_textbox_colorized,
  margins = dpi(15),
  widget = wibox.container.margin,
})
