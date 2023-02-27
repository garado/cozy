
-- █▀▀ ▄▀█ █▀█ █▄░█ █ █▄░█ █▀▀ █▀ 
-- ██▄ █▀█ █▀▄ █░▀█ █ █░▀█ █▄█ ▄█ 

-- Infobox widget showing pay estimates from hourly jobs.

local wibox = require("wibox")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local ui = require("helpers.ui")
local time = require("core.system.time")

local jobs = require("cozyconf").time.jobs

local function create_header(text)
  return wibox.widget({
    markup = ui.colorize(string.upper(text), beautiful.fg_1),
    font   = beautiful.font_reg_s,
    align  = "center",
    widget = wibox.widget.textbox,
  })
end

local function create_earnings_estimate(job)
  local hours = 10
  local todaytext = "10 hours today ($239.20)"
  local pptext = "10 hours this period ($239.20)"

  return wibox.widget({
    create_header(job.name),
    {
      markup = ui.colorize(todaytext, beautiful.fg_0),
      align  = "center",
      font   = beautiful.font_reg_s,
      widget = wibox.widget.textbox,
    },
    {
      markup = ui.colorize(pptext, beautiful.fg_0),
      align  = "center",
      font   = beautiful.font_reg_s,
      widget = wibox.widget.textbox,
    },
    spacing = dpi(5),
    layout  = wibox.layout.fixed.vertical,
  })
end

local widget = wibox.widget({
  {
    markup = ui.colorize("Earnings", beautiful.fg_0),
    font   = beautiful.font_reg_l,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  },
  spacing = dpi(10),
  widget  = wibox.layout.fixed.vertical,
})

for i = 1, #jobs do
  local est = create_earnings_estimate(jobs[i])
  widget:add(est)
end

return widget
