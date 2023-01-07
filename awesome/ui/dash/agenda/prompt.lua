
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

-- A text field to get user input for adding and modifying tasks.
-- This only handles the prompt, not any commands.

local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")
local dpi   = xresources.apply_dpi
local pango_bold  = require("helpers.core").pango_bold

local agenda = require("core.system.cal")

-------------------------

local prompt_textbox = wibox.widget({
  font    = beautiful.base_small_font,
  widget  = wibox.widget.textbox,
})

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function agenda_input(type, prompt, text)
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

      agenda:emit_signal("input::complete", type, input)
    end,
    }
end

--- Generates the prompt to display based on type of input requested,
-- then calls function to actually start the prompt
agenda:connect_signal("input::request", function(_, type)
  print("prompt::caught input_request signal")

  local prompt_options = {
    ["add"]       = "Add event (title ; location ; when ; duration): ",
    ["modify"]    = "Modify: (t)itle (l)ocation (w)hen (d)uration ",
    ["delete"]    = "Delete event? (y/n) ",
    ["refresh"]   = "Refresh events? (y/n) ",
    ["mod_title"] = "Modify title: ",
    ["mod_loc"]   = "Modify location: ",
    ["mod_when"]  = "Modify when: ",
    ["mod_dur"]   = "Modify duration: ",
    -- ["search"]    = "/",
  }

  local prompt = prompt_options[type]
  if not prompt then return end

  if type == "modify" then
    prompt_textbox:set_markup_silently(prompt)
    return
  end

  agenda_input(type, prompt_options[type], "")
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
