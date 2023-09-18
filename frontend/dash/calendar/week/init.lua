
-- █░█░█ █▀▀ █▀▀ █▄▀ 
-- ▀▄▀▄▀ ██▄ ██▄ █░█ 

local ui = require("utils.ui")
local wibox = require("wibox")
local cal   = require("backend.system.calendar")
local keynav = require("modules.keynav")
local awful  = require("awful")
local gears  = require("gears")
local dash   = require("backend.cozy").dash
local beautiful = require("beautiful")
local mathutils = require("utils.math")

local SECONDS_IN_WEEK = 24 * 60 * 60 * 7

local eventbox  = require(... .. ".eventbox")
local nowline   = require(... .. ".nowline")()
local gridlines = require(... .. ".gridlines")
local hourlabels, daylabels = require(... .. ".labels")()


-- ▀█▀ ▄▀█ █▄▄    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- ░█░ █▀█ █▄█    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local actions = {
  {
    text = "Refresh",
    func = function() cal:update_cache() end,
  },
  {
    text = "Today",
    func = function()
      if cal.weekview_cur_offset == 0 then return end
      cal.weekview_cur_offset = 0
      cal:emit_signal("weekview::change_week")
    end,
  },
  {
    text = "<",
    func = function()
      cal.weekview_cur_offset = cal.weekview_cur_offset - SECONDS_IN_WEEK
      cal:emit_signal("weekview::change_week")
    end,
  },
  {
    text = ">",
    func = function()
      cal.weekview_cur_offset = cal.weekview_cur_offset + (SECONDS_IN_WEEK)
      cal:emit_signal("weekview::change_week")
    end,
  },
}

local function update_cal_header_titles()
  local ts = cal:get_weekview_start_ts() + cal.weekview_cur_offset

  local title_month_text
  local month_at_week_start = os.date("%b", ts)
  local month_at_week_end   = os.date("%b", ts + SECONDS_IN_WEEK)
  if month_at_week_start ~= month_at_week_end then
    title_month_text = month_at_week_start .. ' - ' .. month_at_week_end
  else
    title_month_text = month_at_week_start
  end

  local markup = ui.colorize(title_month_text, beautiful.neutral[100]) ..
                 ui.colorize(os.date(" %Y", ts), beautiful.neutral[400])
  cal:emit_signal("header::update_title", markup)

  -- Calculate week number (1-52) using day of year.
  local week_num = mathutils.round(os.date("*t", ts).yday / 7) + 1
  markup = ui.colorize("Week " .. week_num, beautiful.neutral[500])
  cal:emit_signal("header::update_subtitle", markup)
end

update_cal_header_titles()
cal:connect_signal("weekview::change_week", update_cal_header_titles)
cal:connect_signal("weekview::update_header", update_cal_header_titles)

cal:connect_signal("weekview::change_week", function()
  nowline:emit_signal("widget::redraw_needed")
end)


-- █▄▀ █▀▀ █▄█ █▄░█ ▄▀█ █░█ 
-- █░█ ██▄ ░█░ █░▀█ █▀█ ▀▄▀ 

local function send_popup_close_signal()
  dash:emit_signal("calpopup::hide")
end

local nav_cal_week = keynav.area({
  name = "nav_cal_week",
  autofocus = true,
  items = {
    eventbox.area,
  },
  keys = {
    ["r"] = function()
      cal:emit_signal("refresh")
    end,
    ["t"] = function()
      cal:emit_signal("week::jump_today")
    end,
    ["H"] = function()
      cal:emit_signal("week::previous")
      eventbox.area.active_element = nil
    end,
    ["L"] = function()
      cal:emit_signal("week::next")
      eventbox.area.active_element = nil
    end,
    ["J"] = function() cal:increment_hour() end,
    ["K"] = function() cal:decrement_hour() end,
    ["h"] = send_popup_close_signal,
    ["j"] = send_popup_close_signal,
    ["k"] = send_popup_close_signal,
    ["l"] = send_popup_close_signal,
  },
  override_keys = {
    ["zz"] = function() cal:jump_middle_hour() end,
    ["gg"] = function() cal:jump_start_hour()  end,
    ["GG"] = function() cal:jump_end_hour()    end,
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

-- Mouse scrolling adjusts hours shown
content.buttons = gears.table.join({
  awful.button({}, 4, function()
    cal:decrement_hour()
  end),
  awful.button({}, 5, function()
    cal:increment_hour()
  end),
})

return function()
  return actions, content, nav_cal_week
end
