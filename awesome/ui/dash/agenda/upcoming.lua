
-- █░█ █▀█ █▀▀ █▀█ █▀▄▀█ █ █▄░█ █▀▀ 
-- █▄█ █▀▀ █▄▄ █▄█ █░▀░█ █ █░▀█ █▄█ 

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local textbox = require("ui.widgets.text")
local gears = require("gears")
local cal = require("core.system.cal")

local colorize = require("helpers.ui").colorize_text

-- Assemble a single event box
local function create_eventbox(startdate, starttime, endtime, title, place)
  local accent = beautiful.random_accent_color()

  local name = textbox({
    text = title,
    color = accent,
    bold = true,
    size = 14,
    halign = "left",
    valign = "center",
  })

  local date = textbox({
    text = startdate,
    size = 12,
    bold = true,
    halign = "left",
    valign = "center",
  })

  local times = textbox({
    text = starttime .. " - " .. endtime,
    size = 12,
    halign = "left",
    valign = "center",
  })

  local _place = textbox({
    text = place,
    size = 12,
    halign = "left",
    valign = "center",
  })

  local details = wibox.widget({
    name,
    {
      date,
      times,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal,
    },
    _place,
    spacing = dpi(2),
    forced_width = dpi(400),
    layout = wibox.layout.fixed.vertical,
  })

  local accent_bar = wibox.widget({
    bg = accent,
    forced_width = dpi(5),
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background,
  })

  local eventbox = wibox.widget({
    -- {
      {
        {
          accent_bar,
          details,
          spacing = dpi(10),
          layout = wibox.layout.fixed.horizontal,
        },
        top    = dpi(5),
        left   = dpi(10),
        right  = dpi(10),
        bottom = dpi(5),
        widget = wibox.container.margin,
      },
      widget = wibox.container.place,
    -- },
    -- forced_height = dpi(90),
    -- forced_width = dpi(300),
    -- bg = beautiful.bg_l0,
    -- shape = gears.shape.rounded_rect,
    -- widget = wibox.container.background,
  })

  return eventbox
end

local event_list = wibox.widget({
  spacing = dpi(10),
  layout = wibox.layout.fixed.vertical,
})

cal:connect_signal("ready::upcoming", function()
  local upcoming = cal:get_upcoming_events()
  -- TODO: add placeholder
  -- if #upcoming > 0 then
  --   events:reset()
  -- end

  local max = 5
  for i = 1, #upcoming do
    if i > max then break end
    local date = cal:get_start_date(upcoming[i])
    date = cal:format_date(date)
    local stime = cal:get_start_time(upcoming[i])
    local etime = cal:get_end_time(upcoming[i])
    local desc = cal:get_title(upcoming[i])
    local loc = cal:get_location(upcoming[i])
    local entry = create_eventbox(date, stime, etime, desc, loc)
    event_list:add(entry)
  end
end)

local widget = wibox.widget({
  {
    wibox.widget({
      markup  = colorize("Upcoming", beautiful.fg),
      font    = beautiful.font_name .. "17",
      align   = "center",
      valign  = "center",
      widget  = wibox.widget.textbox,
    }),
    event_list,
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  top = dpi(20),
  bottom = dpi(20),
  widget = wibox.container.margin,
})

return widget
