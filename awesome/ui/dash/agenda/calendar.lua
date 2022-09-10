
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local gfs = require("gears.filesystem")
local dpi = xresources.apply_dpi
local naughty = require("naughty")

-- The following is formatting for the calendar
local styles = {}
local function rounded_shape(size, partial)
  if partial then
    return function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height,
        false, true, false, true, 5)
    end
  else
    return function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, size)
    end
  end
end

styles.month = {
  padding   = 5,
  bg_color  = beautiful.cal_month_bg,
  shape     = rounded_shape(10)
}

styles.normal = {
  shape    = rounded_shape(5)
}

styles.focus  = {
  fg_color = beautiful.cal_focus_fg,
  bg_color = beautiful.cal_focus_bg,
  markup   = function(t) return '<b>' .. t .. '</b>' end,
  shape    = rounded_shape(5),
}

styles.header  = {
  fg_color = beautiful.cal_header_fg,
  markup   = function(t) return '<b>' .. t .. '</b>' end,
  shape    = rounded_shape(10)
}

styles.weekday = {
  fg_color = beautiful.cal_weekday_fg,
  markup   = function(t) return '<b>' .. t .. '</b>' end,
  shape    = rounded_shape(5)
}

local function decorate_cell(widget, flag, date)
  if flag == "monthheader" and not styles.monthheader then
    flag = "header"
  end
  local props = styles[flag] or {}
  if props.markup and widget.get_text and widget.set_markup then
   widget:set_markup(props.markup(widget:get_text()))
  end
  -- Change bg color for weekends
  local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
  --local weekday = tonumber(os.date("%w", os.time(d)))
  --local default_bg = (weekday==0 or weekday==6) and "#232323" or "#383838"
  local default_bg = beautiful.dash_bg
  local ret = wibox.widget {
    {
      widget,
      margins = (props.padding or 2) + (props.border_width or 0),
      widget  = wibox.container.margin
    },
    shape        = props.shape,
    border_color = props.border_color or "#b9214f",
    border_width = props.border_width or dpi(0),
    font         = props.font or beautiful.font,
    fg           = props.fg_color or beautiful.cal_fg,
    bg           = props.bg_color or default_bg,
    widget       = wibox.container.background
  }
  return ret
end

local cal = wibox.widget({
  date = os.date("*t"),
  widget   = wibox.widget.calendar.month,
  font = beautiful.font .. "15",
  fn_embed = decorate_cell,
})

return cal
