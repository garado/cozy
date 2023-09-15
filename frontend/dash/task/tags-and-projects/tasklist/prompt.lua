
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

-- Stuff related to the prompt textbox that appears when editing tasks.

local beautiful  = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local task  = require("backend.system.task")
local fzf = require("modules.fzf")

-- █▀▀ ▄▀█ █░░ █░░ █▄▄ ▄▀█ █▀▀ █▄▀ █▀
-- █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▀█ █▄▄ █░█ ▄█

local keywords = {}

-- Completion with fuzzy find
local function fzf_completion(text, cur_pos, ncomp)
  -- The keywords table may be empty
  if #keywords == 0 then
    return text, text + 1
  end

  -- If no text had been typed yet, then we could start cycling around all
  -- keywords with out filtering and move the cursor at the end of keyword
  if text == nil or #text == 0 then
    ncomp = math.fmod(ncomp - 1, #keywords) + 1
    return keywords[ncomp], #keywords[ncomp] + 2
  end

  -- Filter out only keywords starting with text
  local tmp = fzf.filter(text, keywords, false)

  local matches = {}
  for i = 1, #tmp do
    matches[#matches+1] = keywords[tmp[i][1]]
  end

  -- If there are no matches, just leave out with the current text and position
  if #matches == 0 then
    return text, #text + 1, matches
  end

  -- Cycle around all matches
  ncomp = math.fmod(ncomp - 1, #matches) + 1
  return matches[ncomp], #matches[ncomp] + 1, matches
end

--- @function search_callback
-- @brief Populate keywords{} with task descriptions
local function search_callback()
  local t = task.active_tag
  local p = task.active_project
  local tasks = task.data[t][p]

  -- Don't know if this is the most efficient way to do this.
  for i = 1, #tasks do
    keywords[#keywords+1] = tasks[i].description
  end
end

--- @function mod_project_callback
-- @brief Populate keywords{} with project names
local function mod_project_callback()
  local tag = task.active_tag
  keywords = task.data[tag]
end

--- @function mod_tag_callback
-- @brief Populate keywords{} with tag names
local function mod_tag_callback()
  for tag in pairs(task.data) do
    keywords[#keywords+1] = tag
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
promptbox_colorized:set_fg(beautiful.neutral[100])

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function task_input(type, prompt, text)

  -- Generate completion callback list
  keywords = {}
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
    fg           = beautiful.neutral[100],
    bg_cursor    = beautiful.primary[400],
    textbox      = promptbox,
    completion_callback = fzf_completion,
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
    add         = "Add: ",
    annotation  = "Add annotation: ",
    modify      = "Modify (d)ue, (n)ame, (p)roject, (t)ag, custom (u)da",
    done        = "Mark task as done? (y/n) ",
    delete      = "Delete task? (y/n) ",
    mod_due     = "Modify due: ",
    mod_tag     = "Modify tag: ",
    mod_name    = "Modify name: ",
    mod_clear   = "",
    mod_project = "Modify project: ",
    search      = "/",
    start       = "",
  }

  local text_options = {
    mod_name  = task.active_task.description
  }

  local prompt = "<b>"..prompt_options[type].."</b>"
  local text   = text_options[type]

  -- Modify takes no input; just changes the prompt
  if type == "modify" then
    promptbox.markup = prompt
    return
  end

  -- Start takes no input; just executes immediately
  if type == "start" then
    task:emit_signal("input::complete", type, nil)
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
