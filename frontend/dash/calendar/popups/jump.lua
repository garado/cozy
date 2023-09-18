
-- ░░█ █░█ █▀▄▀█ █▀█
-- █▄█ █▄█ █░▀░█ █▀▀

-- Small popup allowing you to jump to a certain calendar date.

local beautiful = require("beautiful")
local ui = require("utils.ui")
local dpi = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local dash = require("backend.cozy.dash")
local calbackend = require("backend.system.calendar")
local math = math

local SECONDS_IN_DAY  = 24 * 60 * 60
local SECONDS_IN_WEEK = SECONDS_IN_DAY * 7

local calendar = require("frontend.widget.calendar")({
  on_day_press = function(ts)
    -- Find out how many weeks between *right now* and ts
    -- i just know this shit wont make sense to me in 3 months
    local start_offset = tonumber(os.date("%w", ts)) * SECONDS_IN_DAY
    local week_diff = (ts - (start_offset + os.time())) / SECONDS_IN_WEEK
    calbackend.weekview_cur_offset = (math.floor(week_diff) + 1) * SECONDS_IN_WEEK
    calbackend:emit_signal("weekview::change_week")
  end
})

local widget = wibox.widget({
  ui.textbox({
    text  = "Jump to date",
    align = "center",
    font  = beautiful.font_reg_l,
  }),
  calendar,
  spacing = dpi(15),
  layout  = wibox.layout.fixed.vertical,
})

local popup = awful.popup({
  type           = "splash",
  minimum_width  = dpi(370),
  maximum_width  = dpi(370),
  placement      = awful.placement.centered,
  shape          = ui.rrect(),
  ontop          = true,
  visible        = false,
  widget         = wibox.widget({
    {
      widget,
      margins = dpi(30),
      widget  = wibox.container.margin,
    },
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  })
})


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

local show, hide
local nav_calendar

function show()
  popup.screen = awful.screen.focused()
  popup.visible = true
  if nav_calendar then
    nav_calendar:append(calendar.area)
    calendar.area:force_active()
  end
end

function hide()
  popup.visible = false
  if nav_calendar then
    nav_calendar:remove_area("nav_calwidget")
    nav_calendar:force_active()
  end
end

dash.child_popups[#dash.child_popups+1] = "jump"

dash:connect_signal("jump::setstate::toggle", function(_, nav)
  if not nav_calendar and nav then nav_calendar = nav end
  if popup.visible then hide() else show() end
end)

dash:connect_signal("jump::setstate::open", function(_, nav)
  if not nav_calendar and nav then nav_calendar = nav end
  show()
end)

dash:connect_signal("jump::setstate::close", function(_, nav)
  if not nav_calendar and nav then nav_calendar = nav end
  hide()
end)
