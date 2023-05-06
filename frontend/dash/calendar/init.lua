-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local cal   = require("backend.system.calendar")
local btn   = require("frontend.widget.button")
local header = require("frontend.widget.dash.header")
local keynav = require("modules.keynav")
local mathutils = require("utils.math")

local SECONDS_IN_WEEK = 24 * 60 * 60 * 7

local eventbox  = require(... .. ".eventbox")
local nowline   = require(... .. ".nowline")()
local gridlines = require(... .. ".gridlines")
local hourlabels, daylabels = require(... .. ".labels")()


-- ▀█▀ ▄▀█ █▄▄    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- ░█░ █▀█ █▄█    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local calheader = header()

local action_refresh = btn({
  text = "Refresh",
  func = function()
    cal:update_cache()
  end,
})

local action_today = btn({
  text = "Today",
  func = function()
    if cal.weekview_cur_offset == 0 then return end
    cal.weekview_cur_offset = 0
    cal:emit_signal("weekview::change_week")
  end,
})

local action_prev = btn({
  text = "&lt;", -- pango markup doesn't like raw '<' character
  func = function()
    cal.weekview_cur_offset = cal.weekview_cur_offset + (SECONDS_IN_WEEK * -1)
    cal:emit_signal("weekview::change_week")
  end,
})

local action_next = btn({
  text = ">",
  func = function()
    cal.weekview_cur_offset = cal.weekview_cur_offset + (SECONDS_IN_WEEK)
    cal:emit_signal("weekview::change_week")
  end,
})

calheader:add_action(action_refresh)
calheader:add_action(action_today)
calheader:add_action(action_prev)
calheader:add_action(action_next)

local function update_calheader_titles()
  local ts = cal:get_weekview_start_ts() + cal.weekview_cur_offset

  local title_month_text
  local month_at_week_start = os.date("%b", ts)
  local month_at_week_end   = os.date("%b", ts + SECONDS_IN_WEEK)
  if month_at_week_start ~= month_at_week_end then
    title_month_text = month_at_week_start .. ' - ' .. month_at_week_end
  else
    title_month_text = month_at_week_start
  end

  calheader:update_title({
    markup = ui.colorize(title_month_text, beautiful.fg) ..
             ui.colorize(os.date(" %Y", ts), beautiful.neutral[400])
  })

  -- Calculate week number (1-52) using day of year.
  local week_num = mathutils.round(os.date("*t", ts).yday / 7) + 1
  calheader:update_subtitle({
    markup = ui.colorize("Week " .. week_num, beautiful.neutral[500])
  })
end

update_calheader_titles()
cal:connect_signal("weekview::change_week", update_calheader_titles)

cal:connect_signal("weekview::change_week", function()
  nowline:emit_signal("widget::redraw_needed")
end)


-- █▄▀ █▀▀ █▄█ █▄░█ ▄▀█ █░█ 
-- █░█ ██▄ ░█░ █░▀█ █▀█ ▀▄▀ 

local nav_calendar
nav_calendar = keynav.area({
  name = "nav_calendar",
  keys = {
    ["r"] = function()
      action_refresh:emit_signal("button::press")
    end,
    ["t"] = function()
      action_today:emit_signal("button::press")
    end,
    ["h"] = function()
      action_prev:emit_signal("button::press")
    end,
    ["l"] = function()
      action_next:emit_signal("button::press")
    end
  }
})


-- Final assembly of tab contents
local content = wibox.widget({
  hourlabels,
  {
    daylabels,
    {
      gridlines,
      eventbox,
      nowline,
      layout = wibox.layout.stack,
    },
    layout = wibox.layout.ratio.vertical,
  },
  layout = wibox.layout.ratio.horizontal,
})

-- Adjust daylabels, gridlines
content.children[2]:adjust_ratio(1, 0, 0.08, 0.92)

-- Adjust hourlabels + { daylabels, gridlines }
content:adjust_ratio(1, 0, 0.05, 0.95)

local container = wibox.widget({
  calheader,
  content,
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return container, nav_calendar
end
