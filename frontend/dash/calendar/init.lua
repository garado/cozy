
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄

-- Basically a Google Calendar clone.

local ui = require("utils.ui")
local dpi = ui.dpi
local wibox  = require("wibox")
local header = require("frontend.widget.dashheader")
local keynav = require("modules.keynav")
local cal    = require("backend.system.calendar")
local dash = require("backend.cozy.dash")

require(... .. ".popups.add_modify")
local nav_jump_calendar = require(... .. ".popups.jump")

local week_actions, week_content, nav_week = require(... .. ".week")()
-- local schedule_actions, schedule_content, nav_schedule = require(... .. ".schedule")()

local calheader, container

local nav_calendar
nav_calendar = keynav.area({
  name = "nav_calendar",
  items = {
    nav_week,
  },
  keys = {
    ["Shift_R!"] = function() -- Shift_R + 1
      calheader:get_pages()[1]:emit_signal("button::press")
    end,
    ["Shift_R@"] = function() -- Shift_R + 2
      calheader:get_pages()[2]:emit_signal("button::press")
    end,
    ["a"] = function()
      dash:emit_signal("add::setstate::toggle")
    end,
    ["c"] = function()
      dash:emit_signal("jump::setstate::toggle", nav_calendar)
    end
  },
})

calheader = header({
  title_text = "",
  -- Disabling schedule page until I actually implement it
  -- pages = {
  --   {
  --     text = "Week",
  --     func = function(self)
  --       self:emit_signal("page::switch::week")
  --       if container then container:set(2, week_content) end
  --     end
  --   },
  --   {
  --     text = "Schedule",
  --     func = function(self)
  --       self:emit_signal("page::switch::schedule")
  --       if container then container:set(2, schedule_content) end
  --     end
  --   },
  -- },
  actions = week_actions
})


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█

cal:connect_signal("refresh", function()
  calheader.actions[1]:emit_signal("button::press")
end)

cal:connect_signal("week::jump_today", function()
  calheader.actions[2]:emit_signal("button::press")
end)

cal:connect_signal("week::previous", function()
  calheader.actions[3]:emit_signal("button::press")
end)

cal:connect_signal("week::next", function()
  calheader.actions[4]:emit_signal("button::press")
end)

cal:connect_signal("header::update_title", function(_, mkup)
  calheader:update_title({ markup = mkup })
end)

cal:connect_signal("header::update_subtitle", function(_, mkup)
  calheader:update_subtitle({ markup = mkup })
end)

-- Initial update of header text
cal:emit_signal("weekview::update_header")

container = wibox.widget({
  calheader,
  week_content,
  forced_width = dpi(2000),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }),
  nav_calendar
end
