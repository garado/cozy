
-- █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▀ 
-- ██▄ ▀▄▀ ██▄ █░▀█ ░█░ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local cal   = require("backend.system.calendar")

local label = ui.textbox({
  text = "You have 3 events today.",
})

function label:update(num_events)
  local plural = num_events == 1 and "" or "s"
  self.markup  = ui.colorize("You have ", beautiful.fg) ..
                 ui.colorize(num_events .. " event" .. plural, beautiful.primary[400]) ..
                 ui.colorize(" today.", beautiful.fg)
end

label:update(4)

-------------------------

local function gen_event(e)
  return wibox.widget({
    ui.textbox({
      text = "󰃮",
      font = beautiful.font_reg_l,
      color = beautiful.neutral[300],
    }),
    {
      ui.textbox({
        text = e[1],
        font = beautiful.font_med_s,
      }),
      ui.textbox({
        text = "1:30 - 2:45",
        color = beautiful.neutral[300],
      }),
      spacing = dpi(5),
      layout  = wibox.layout.fixed.vertical,
    },
    spacing = dpi(15),
    layout  = wibox.layout.fixed.horizontal,
  })
end

local list = wibox.widget({
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

function list:add_event(e)
  self:add(gen_event(e))
end

list:add_event({ "Meeting with Jeff" })
list:add_event({ "Animal shelter orientation" })
list:add_event({ "Gym" })
list:add_event({ "Meeting with Jeff" })

return wibox.widget({
  label,
  list,
  spacing = dpi(15),
  layout = wibox.layout.fixed.vertical,
})
