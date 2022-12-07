
-- █▀▄ ▄▀█ █▀ █░█    █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▄▀ █▀█ ▄█ █▀█    █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local ui = require("helpers.ui")

local _dash = {}

function _dash.format_due_date(due)
  if not due or due == "" then return "no due date" end

  -- taskwarrior returns due date as string
  -- convert that to a lua timestamp
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = due:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })

  -- turn timestamp into human-readable format
  local now = os.time()
  local time_difference = ts - now
  local abs_time_difference = math.abs(time_difference)
  local days_rem = math.floor(abs_time_difference / 86400)
  local hours_rem = math.floor(abs_time_difference / 3600)

  -- due date formatting
  local due_date_text
  if days_rem >= 1 then -- in x days / x days ago
    due_date_text = days_rem .. " day"
    if days_rem > 1 then
      due_date_text = due_date_text .. "s"
    end
  else -- in x hours / in <1 hour / etc
    if hours_rem == 1 then
      due_date_text = hours_rem .. " hour"
    elseif hours_rem < 1 then
      due_date_text = "&lt;1 hour"
    else
      due_date_text = hours_rem .. " hours"
    end
  end

  local due_date_color = beautiful.fg_sub
  if time_difference < 0 then -- overdue
    due_date_text = due_date_text .. " ago"
    due_date_color = beautiful.red
  else
    due_date_text = "in " .. due_date_text
  end

  return due_date_text, due_date_color
end

-- Strips input of all pango markup and returns only text
-- Breaks if the actual text contains < or > !!!
-- (Not fully tested)
function _dash.remove_pango(markup)
  return string.gsub(markup, "%b<>", "")
end

function _dash.widget_header(text)
  return wibox.widget({
    markup = ui.colorize_text(text, beautiful.dash_header_fg),
    font = beautiful.alt_font_name .. "Light 20",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  })
end

function _dash.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function _dash.datestr_to_ts(datestring)
  local pattern = "(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z"
  local xyear, xmon, xday, xhr, xmin, xsec = datestring:match(pattern)
  local ts = os.time({
    year = xyear, month = xmon, day = xday,
    hour = xhr, min = xmin, sec = xsec })
  ts = ts - (8 * 60 * 60) -- pacific time is 8 hours behind utc
  return ts
end

return _dash
