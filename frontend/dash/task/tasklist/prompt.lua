
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

-- Stuff related to the prompt textbox that appears when editing tasks.

local beautiful  = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local bold  = require("utils.string").pango_bold
local task  = require("backend.system.task")

-- █▀▀ ▄▀█ █░░ █░░ █▄▄ ▄▀█ █▀▀ █▄▀ █▀
-- █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▀█ █▄▄ █░█ ▄█

local comp_callback_table = {}
local function comp_callback(command_before_comp, cur_pos_before_comp, ncomp)
  return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, comp_callback_table)
end

local function search_callback()
  local t = task.active_tag
  local p = task.active_project
  local tasks = task.data[t][p]

  -- Don't know if this is the most efficient way to do this.
  for i = 1, #tasks do
    comp_callback_table[#comp_callback_table+1] = tasks[i].description
  end
end

local function mod_project_callback()
  local tag = task.active_tag
  comp_callback_table = task.data[tag]
end

local function mod_tag_callback()
  for tag in pairs(task.data) do
    comp_callback_table[#comp_callback_table+1] = tag
  end
end

-- █░█ █
-- █▄█ █

local promptbox = wibox.widget({
  font   = beautiful.font_reg_s,
  widget = wibox.widget.textbox,
})

local promptbox_colorized = wibox.container.background()
promptbox_colorized:set_widget(promptbox)
promptbox_colorized:set_fg(beautiful.fg)

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function task_input(type, prompt, text)

  -- Generate completion callback list
  comp_callback_table = {}
  if type == "mod_project" then
    mod_project_callback()
  elseif type == "mod_tag" then
    mod_tag_callback()
  elseif type == "search" then
    search_callback()
  end

  awful.prompt.run {
    font         = beautiful.font_reg_s,
    prompt       = prompt or "",
    text         = text or "",
    fg           = beautiful.fg,
    bg_cursor    = beautiful.primary[400],
    textbox      = promptbox,
    completion_callback = comp_callback,
    exe_callback = function(input)
      if not input or #input == 0 then
        task:emit_signal("input::cancelled")
        return
      end
      task:emit_signal("input::complete", type, input)
    end,
  }
end

--- Generates the prompt to display based on type of input requested,
-- then calls function to actually start the prompt
task:connect_signal("input::request", function(_, type)
  local prompt_options = {
    add       = "Add: ",
    modify    = "Modify (d)ue, (n)ame, (p)roject, (t)ag",
    done      = "Mark task as done? (y/n) ",
    delete    = "Delete task? (y/n) ",
    mod_due   = "Modify due: ",
    mod_tag   = "Modify tag: ",
    mod_name  = "Modify name: ",
    mod_clear = "",
    mod_project = "Modify project: ",
    search    = "/",
  }

  local text_options = {
    mod_name  = task.active_task.description
  }

  local prompt = bold(prompt_options[type])
  local text   = text_options[type]

  -- Modify and Start take no input - they just execute
  if type == "modify" or type == "start" then
    promptbox.markup = prompt
    return
  end

  -- Just clear the prompt
  if type == "mod_clear" then
    promptbox.markup = ""
    return
  end

  task_input(type, prompt, text)
end)

return promptbox_colorized
