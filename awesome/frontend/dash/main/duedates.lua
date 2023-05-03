
-- █▀▄ █░█ █▀▀    █▀▄ ▄▀█ ▀█▀ █▀▀ █▀ 
-- █▄▀ █▄█ ██▄    █▄▀ █▀█ ░█░ ██▄ ▄█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")


-- █░░ ▄▀█ █▄▄ █▀▀ █░░ 
-- █▄▄ █▀█ █▄█ ██▄ █▄▄ 

local label = ui.textbox({
  text = "nil",
  font = beautiful.font_reg_s,
  align = "left",
})

function label:update_tasks(today, soon)
  self.today = today
  self.soon  = soon
  local today_plural = self.today == 1 and "" or "s"
  local soon_plural  = self.soon  == 1 and "" or "s"
  local today_tasks = self.today .. " task" .. today_plural
  local soon_tasks  = self.soon  .. " task" .. soon_plural

  self.markup = ui.colorize("You have ", beautiful.fg) ..
                ui.colorize(today_tasks, beautiful.primary[400]) ..
                ui.colorize(" due today and ", beautiful.fg) ..
                ui.colorize(soon_tasks, beautiful.primary[400]) ..
                ui.colorize(" due soon.", beautiful.fg)
end

label:update_tasks(3, 5)

local function gen_task(e)
  return wibox.widget({
    ui.textbox({
      text = "󰄱",
      font = beautiful.font_reg_l,
      color = beautiful.neutral[300],
    }),
    {
      ui.textbox({
        text = e[1],
        font = beautiful.font_med_s,
      }),
      ui.textbox({
        text = "Midnight",
        color = beautiful.neutral[300],
      }),
      spacing = dpi(5),
      layout  = wibox.layout.fixed.vertical,
    },
    spacing = dpi(15),
    layout  = wibox.layout.fixed.horizontal,
  })
end

-- ▀█▀ █▀█ █▀▄ ▄▀█ █▄█ 
-- ░█░ █▄█ █▄▀ █▀█ ░█░ 

local todaylist = wibox.widget({
  ui.textbox({
    text = "TODAY",
    font = beautiful.font_med_xs,
  }),
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

function todaylist:add_task(e)
  self:add(gen_task(e))
end

function todaylist:reset()
  for i = 2, #self.children do
    self:remove(i)
  end
end

todaylist:add_task({ "Meeting with Jeff" })
todaylist:add_task({ "Animal shelter orientation" })
todaylist:add_task({ "Gym" })
todaylist:add_task({ "Meeting with Jeff" })

-- █░█ █▀█ █▀▀ █▀█ █▀▄▀█ █ █▄░█ █▀▀ 
-- █▄█ █▀▀ █▄▄ █▄█ █░▀░█ █ █░▀█ █▄█ 

local upcominglist = wibox.widget({
  ui.textbox({
    text = "UPCOMING",
    font = beautiful.font_med_xs,
  }),
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

function upcominglist:add_task(e)
  self:add(gen_task(e))
end

function upcominglist:reset()
  for i = 2, #self.children do
    self:remove(i)
  end
end

upcominglist:add_task({ "Meeting with Jeff" })
upcominglist:add_task({ "Animal shelter orientation" })
upcominglist:add_task({ "Gym" })

return wibox.widget({
  label,
  {
    todaylist,
    upcominglist,
    spacing = dpi(40),
    layout  = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})
