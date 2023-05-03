
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

-- █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local title = ui.textbox({
  text = "Project name",
  align = "left",
  font = beautiful.font_reg_l,
})

local done = ui.textbox({
  text = "21 done",
  align = "left",
  color = beautiful.neutral[400],
})

local remaining = ui.textbox({
  text = "2 rem",
  align = "left",
  color = beautiful.neutral[400],
})

local wait_status = ui.textbox({
  text = " (Wait Shown)",
  align = "left",
  color = beautiful.neutral[400],
})

local percent = ui.textbox({
  text = "88%",
  align = "right",
  color = beautiful.neutral[200],
  font = beautiful.font_reg_l,
})

local progress = wibox.widget({
  value = 88,
  max_value = 100,
  background_color = beautiful.neutral[700],
  forced_height = dpi(8),
  shape = ui.rrect(),
  color = beautiful.random_accent_color(),
  widget = wibox.widget.progressbar,
})

local header = wibox.widget({
  {
    title,
    percent,
    layout = wibox.layout.align.horizontal,
  },
  {
    done,
    ui.textbox({
      text = " - ",
      color = beautiful.neutral[400],
    }),
    remaining,
    wait_status,
    layout = wibox.layout.fixed.horizontal,
  },
  progress,
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

----------------------

-- ▀█▀ ▄▀█ █▀ █▄▀ █▀ 
-- ░█░ █▀█ ▄█ █░█ ▄█ 

local function gen_task(task)
end

local tasks = wibox.widget({
  layout = wibox.layout.fixed.vertical,
  -------
})

local contents = wibox.widget({
  header,
  tasks,
  layout = wibox.layout.fixed.vertical,
})

return function()
  return ui.dashbox(contents)
end
