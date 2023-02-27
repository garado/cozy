
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
local vpad    = require("helpers.ui").vertical_pad
local journal = require("core.system.journal")

journal.is_locked = true

-- █░█ █ 
-- █▄█ █ 

local prompt_textbox = wibox.widget({
  align   = "center",
  valign  = "center",
  font    = beautiful.font_reg_s,
  widget  = wibox.widget.textbox,
})

-- Obscure password text as user is typing
prompt_textbox:connect_signal("widget::redraw_needed", function(self)
  local text = self.text:gsub("[%a%d]", "*")
  self:set_markup_silently(colorize(text, beautiful.primary_0))
end)

local header = wibox.widget({
  markup = colorize(" Log is locked", beautiful.fg_0),
  font   = beautiful.font_reg_l,
  align  = "center",
  valign = "center",
  widget = wibox.widget.textbox,
})

local subheader = wibox.widget({
  markup = colorize("Enter passcode to proceed", beautiful.fg_0),
  font   = beautiful.base_med_font,
  align  = "center",
  valign = "center",
  forced_height = dpi(50),
  widget = wibox.widget.textbox,
})

local widget = wibox.widget({
  {
    header,
    {
      {
        wibox.widget({
          markup = colorize("Password: ", beautiful.fg_0),
          widget = wibox.widget.textbox,
        }),
        prompt_textbox,
        spacing = dpi(15),
        halign  = "center",
        valign  = "center",
        layout  = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    },
    vpad(dpi(100)),
    layout = wibox.layout.fixed.vertical,
  },
  fill_vertical = true,
  widget = wibox.container.place,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

--- Starts prompt to get user input.
-- @param type The action type.
-- @param prompt The prompt to display.
-- @param text The initial textbox text.
local function password_input()
  awful.prompt.run {
    font         = beautiful.font_reg_s,
    fg           = beautiful.fg_0,
    bg           = beautiful.task_prompt_textbg,
    shape        = gears.shape.rounded_rect,
    bg_cursor    = beautiful.primary_0,
    textbox      = prompt_textbox,
    exe_callback = function(input)
      if not input or #input == 0 then return end
      journal:emit_signal("input_complete", input)
    end,
  }
end

local function lock()
  local markup = colorize(" Locked", beautiful.fg_0)
  header:set_markup_silently(markup)
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

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
