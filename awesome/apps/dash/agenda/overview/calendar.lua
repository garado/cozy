
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

-- Interactive calendar
-- TODO add deadlines

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local navbase = require("modules.keynav.navitem").Base
local navbg = require("modules.keynav.navitem").Background
local gears = require("gears")
local cal = require("core.system.cal")
local dash = require("core.cozy.dash")

local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")

-----------------------------------------------------------

local today = tonumber(os.date("%d"))

local febdays = (tonumber(os.date("%Y")) % 400 == 0 and 29) or 28
local DAYS_IN_MONTH = { 31, febdays, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
local MONTH_NAMES = { "January", "February", "March", "April", "May",
  "June", "July", "August", "September", "October", "November", "December" }

local NEXT = 1
local PREV = -1

local calendar

local nav_cal = area({
  name      = "nav_cal",
  circular  = true,
  is_grid   = true,
  grid_cols = 7,
  keys = {
    ["t"] = function() calendar:jump_to_today()   end,
    ["H"] = function() calendar:iter_month(PREV)  end,
    ["L"] = function() calendar:iter_month(NEXT)  end,
  }
})

-----------------------------------------------------------

-- █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

--- Determines the heatmap color based on a number of events.
-- @param base    Middle color
-- @param hours   Number of hours.
local function heat(base, events)
  local MAX_EVENTS = 5
  events = events > MAX_EVENTS and MAX_EVENTS or events

  -- Shitty default algorithm
  -- To get the right heat color, we modify the base color's lightness.
  -- The range of valid lightness values is 0 - 1.
  if not beautiful.gradient then
    if events > (MAX_EVENTS / 2) then
      local lmod = events * 0.1
      if lmod > 1 then lmod = 1 end
      return color.pywal_lighten(base, lmod)
    elseif events < (MAX_EVENTS / 2) then
      local lmod = ((MAX_EVENTS / 2) - events) * 0.37
      return color.pywal_darken(base, lmod)
    else
      return base
    end
  else
    return beautiful.gradient[events]
  end
end

-----------------------------------------------------------

-- █▀▀ █▀█ █▀█ █▀▀ 
-- █▄▄ █▄█ █▀▄ ██▄ 

--- Creates SMTWTFS week labels.
local function create_week_label()
  local labels = { "S", "M", "T", "W", "T", "F", "S" }

  local week_label_cont = wibox.widget ({
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal,
  })

  for i = 1, 7, 1 do
    local label = wibox.widget({
      markup    = colorize(labels[i], beautiful.fg_1),
      font      = beautiful.font_reg_s,
      align     = "center",
      valign    = "center",
      forced_width = dpi(35),
      widget    = wibox.widget.textbox,
    })
    week_label_cont:add(label)
  end

  return week_label_cont
end

--- Create wibox and navitem for a single day of the calendar.
-- @param date    The date (1-31)
-- @param is_valid   True if day within month to display, false otherwise
local function create_daybox(date, month, year, is_valid)
  local cnt = cal:get_num_events(tonumber(month), tonumber(date))
  local heat_color = (is_valid and cnt > 0) and heat(beautiful.primary_0, cnt) or nil

  local fg = is_valid and beautiful.fg_0 or beautiful.fg_1

  local day = wibox.widget({
    { -- Date
      markup  = colorize(date, fg),
      font    = beautiful.font_reg_s,
      align   = "center",
      valign  = "center",
      widget  = wibox.widget.textbox,
    },
    -- Heatmap background color
    bg = heat_color,
    forced_width  = dpi(35),
    forced_height = dpi(35),
    shape = gears.shape.circle,
    widget = wibox.container.background,
  })

  -- New class for keyboard navigation
  local navday = navbase({
    widget = day,
    date   = date,
    month  = month,
    year   = year,
    select_on = function(self)
      self.selected = true
      self.widget.border_width = dpi(3)
      if self.date == today then -- todaybox is white
        self.widget.border_color = beautiful.primary_0
      else
        self.widget.border_color = beautiful.fg_0
      end
    end,
    select_off = function(self)
      self.selected = false
      self.widget.border_width = dpi(0)
    end,
    release = function()
      local strdate = year .. '-' .. string.format('%02d', month) .. '-' .. string.format('%02d', date)
      cal:fetch_upcoming(strdate)
      cal:emit_signal("selected::date", year, month, date)
    end
  })

  return day, navday
end

--- Create a widget containing all of the days within a calendar.
-- @param month   The month (as an integer).
-- @param year    The year.
local function create_month_widget(month, year)
  local days_in_month = DAYS_IN_MONTH[month]

  local calgrid = wibox.widget({
    forced_num_cols = 7,
    orientation = "vertical",
    homogeneous = true,
    spacing = dpi(20),
    layout  = wibox.layout.grid,
    -----
    get_daybox = function(self, idx)
      return self.children[idx]
    end
  })

  -- Get date of first day of the month.
  -- This is a number 0-6 (Sunday - Saturday)
  local fday = os.date("%w", os.time{ year=year, month=month, day=1, hour=0, sec=0 })

  -- If the first day of the month doesn't start on Sunday, then we should
  -- backfill with days from last month
  if fday ~= 0 then
    local last_month_idx = month - 1
    if last_month_idx == 0 then last_month_idx = 12 end
    local days_last_month = DAYS_IN_MONTH[last_month_idx]
    for i = fday - 1, 0, -1 do
      local backfilled_date = days_last_month - i
      local day = create_daybox(backfilled_date, month, year, false)
      calgrid:add(day)
    end
  end

  for i = 1, days_in_month do
    local day, navday = create_daybox(i, month, year, true)
    calgrid:add(day)
    nav_cal:append(navday)
  end

  -- If the last day of the month doesn't end on Saturday (day of week == 6),
  -- fill with days from next month
  local lday = os.date("%w", os.time{ year=year, month=month, day=days_in_month, hour=0, sec=0 })
  for i = 1, 6 - lday do
    local day = create_daybox(i, month, year, false)
    calgrid:add(day)
  end

  -- Invert todaybox colors
  if month == tonumber(os.date("%m")) and year == tonumber(os.date("%Y")) then
    local todaybox = calgrid:get_daybox(today)
    todaybox.bg = beautiful.fg_0
    todaybox.children[1]:set_markup_silently(colorize(today, beautiful.fg_1))
  end

  return wibox.widget({
    calgrid,
    widget = wibox.container.place,
  })
end

-----------------------------------------------------------

-- █░█ █    ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▄█ █    █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

-- Putting all of the wiboxes together.

local month_label = wibox.widget({
  id      = "month_label",
  markup  = colorize(os.date("%B %Y"), beautiful.fg_0),
  font    = beautiful.font_reg_l,
  align   = "center",
  valign  = "center",
  widget  = wibox.widget.textbox,
  ----
  set_label = function(self, monthnum, year)
    local text = MONTH_NAMES[monthnum] .. " " .. year
    self:set_markup_silently(colorize(text, beautiful.fg_0))
  end
})

calendar = wibox.widget({
  month_label,
  create_week_label(),
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

function calendar:get_daybox(idx)
  self.children[3]:get_daybox(idx)
end

function calendar:update(month, year)
  month = month or tonumber(os.date("%m"))
  year  = year  or tonumber(os.date("%Y"))

  self.month = month
  self.year  = year

  nav_cal:remove_all_items()
  local monthwidget = create_month_widget(month, year)
  if not self.children[3] then
    self:add(monthwidget)
  else
    self:set(3, monthwidget)
  end

  local mlabel = self.children[1]
  mlabel:set_label(month, year)
end

function calendar:iter_month(dir)
  local newmonth = self.month + dir
  local newyear  = self.year
  if newmonth == 0 then
    newmonth = 12
    newyear  = self.year - 1
  elseif newmonth > 12 then
    newmonth = 1
    newyear  = self.year + 1
  end
  dash:emit_signal("agenda::calendar::redraw", newmonth, newyear)
end

function calendar:jump_to_today()
  cal:fetch_upcoming()
  cal:fetch_month(os.date("%m"), os.date("%Y"))
  cal:emit_signal("header::reset")
end

local calendar_container = wibox.widget({
  calendar,
  widget = wibox.container.place,
})

local final_widget = box(calendar_container, dpi(430), dpi(440), beautiful.dash_widget_bg)
nav_cal.widget = navbg({ widget = final_widget.children[1] })

dash:connect_signal("agenda::calendar::redraw", function(_, month, year)
  calendar:update(month, year)
end)

return function()
  calendar:update()
  return final_widget, nav_cal
end
