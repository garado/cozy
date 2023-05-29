
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

local beautiful  = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local bold  = require("utils.string").pango_bold
local task  = require("backend.system.task")

--- @brief Completion callback for modifying task name
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
  print('Starting task input')

  -- local comp_callback   = get_completion_callback(type)
  awful.prompt.run {
    font         = beautiful.font_reg_s,
    prompt       = prompt or "",
    text         = text or "",
    fg           = beautiful.fg,
    bg_cursor    = beautiful.primary[400],
    textbox      = promptbox,
    exe_callback = function(input)
      if not input or #input == 0 then
        task:emit_signal("input::cancelled")
        return
      end
      print('frontend:prompt: input complete')
      task:emit_signal("input::complete", type, input)
    end,
    -- completion_callback = comp_callback,
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
  }

  local text_options = {
    search   = "/",
    mod_name = task.active_task.description or "asdfadsf",
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
