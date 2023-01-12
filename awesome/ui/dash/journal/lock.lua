
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░    █░░ █▀█ █▀▀ █▄▀ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄    █▄▄ █▄█ █▄▄ █░█ 

-- Lockscreen and password prompt

local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local dash    = require("core.cozy.dash")
local beautiful   = require("beautiful")
local colorize    = require("helpers").ui.colorize_text
local xresources  = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local journal = require("core.system.journal")

local kprompt = require("modules.kasperprompt")

journal.is_locked = true

-- █░█ █ 
-- █▄█ █ 

local prompt_textbox = wibox.widget({
  {
    align   = "vertical",
    valign  = "vertical",
    font    = beautiful.base_small_font,
    widget  = wibox.widget.textbox,
  },
  valign  = "center",
  widget  = wibox.container.place,
})

local header = wibox.widget({
  markup = colorize(" Log is locked", beautiful.fg),
  font   = beautiful.alt_font_name .. "Regular 50",
  align  = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})

local subheader = wibox.widget({
  markup = colorize("Enter passcode to proceed", beautiful.fg),
  font   = beautiful.base_med_font,
  align  = "center",
  valign = "center",
  forced_height = dpi(50),
  widget = wibox.widget.textbox,
})

local widget = wibox.widget({
  header,
  subheader,
  prompt_textbox,
  valign = "center",
  layout = wibox.layout.fixed.vertical,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function password_input()
  awful.prompt.run {
    font         = beautiful.base_small_font,
    text         = "",
    fg           = beautiful.fg,
    bg           = beautiful.task_prompt_textbg,
    shape        = gears.shape.rounded_rect,
    bg_cursor    = beautiful.main_accent,
    textbox      = prompt_textbox.children[1],
    exe_callback = function(input)
      if not input or #input == 0 then return end
      journal:emit_signal("input_complete", input)
    end,
  }
end

local function lock()
  local markup = colorize(" Log is locked", beautiful.fg)
  header:set_markup_silently(markup)
end

dash:connect_signal("tabswitch", function(_, tab)
  if tab == "journal" and journal.is_locked then
    password_input()
  else
    journal:emit_signal("lock")
  end
end)

journal:connect_signal("lock", function()
  lock()
end)

journal:connect_signal("unlock", function()
end)

return widget
