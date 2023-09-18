
-- █▀▄ █▀▀ ▀█▀ ▄▀█ █ █░░ █▀ 
-- █▄▀ ██▄ ░█░ █▀█ █ █▄▄ ▄█ 

-- Cool little calendar popup. Used for modifying events and
-- showing event details.

-- NOTE: UNUSED

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local dash  = require("backend.cozy").dash
local strutils = require("utils.string")
local calwidget = require("frontend.widget.calendar")

local title = ui.textbox({
  font = beautiful.font_bold_m,
})

local dt_color = beautiful.neutral[300]

local date = ui.textbox({ color = dt_color })
local starttime = ui.textbox({ color = dt_color })
local endtime   = ui.textbox({ color = dt_color })
local datetime = wibox.widget({
  date,
  ui.textbox({ text = "  ·  ", color = dt_color }),
  starttime,
  ui.textbox({ text = " - ", color = dt_color }),
  endtime,
  layout = wibox.layout.fixed.horizontal,
})

local loc_title = ui.textbox()
local loc_subtitle = ui.textbox({
  color = beautiful.neutral[200]
})

local location = wibox.widget({
  ui.textbox({
    text = "",
    font = beautiful.font_reg_m,
  }),
  {
    loc_title,
    loc_subtitle,
    layout = wibox.layout.fixed.vertical,
  },
  spacing = dpi(8),
  layout  = wibox.layout.fixed.horizontal,
})

-- TODO: Super sloppy implementation
function location:update_text(loc)
  local t = ""
  local st = ""

  -- TODO: Match on ', ' instead of just ','
  for i in string.gmatch(loc, "[^,]+") do
    if t == "" then
      t = i
    else
      if st ~= "" then st = st .. ',' end
      st = st .. i
    end
  end

  loc_title:update_text(t)
  loc_subtitle:update_text(st:sub(2)) -- strip leading whitespace
end

-- local location  = ui.textbox()
-- local location_cont = {
--   ui.textbox({
--     text = "",
--     font = beautiful.font_med_m,
--   }),
--   location,
--   spacing = dpi(15),
--   layout  = wibox.layout.fixed.horizontal,
-- }

local widget = wibox.widget({
  title,
  datetime,
  location,
  -- calwidget,
  spacing = dpi(8),
  forced_width = dpi(370),
  layout  = wibox.layout.fixed.vertical,
})

local calpopup = awful.popup({
  type = "splash",
  minimum_width  = dpi(380),
  maximum_width  = dpi(380),
  minimum_height = dpi(100),
  shape = ui.rrect(),
  ontop   = true,
  visible = false,
  widget  = wibox.widget({
    {
      {
        widget,
        margins = dpi(15),
        widget  = wibox.container.margin,
      },
      widget = wibox.container.place,
    },
    bg = beautiful.neutral[700],
    widget = wibox.container.background,
  })
})

dash:connect_signal("calpopup::toggle", function(_, x, y, event)
  if x < dpi(270) then
    calpopup.x = x + dpi(600)
  else
    calpopup.x = x + dpi(50)
  end
  calpopup.y = y + dpi(150)

  title:update_text(event.title)
  starttime:update_text(event.s_time)
  endtime:update_text(event.e_time)
  date:update_text(strutils.dt_convert(event.s_date, "%Y-%m-%d", "%A, %B %d %Y"))
  -- date:update_text(strutils.datetime_to_human(event.s_date))

  if event.loc ~= "" then
    location:update_text(event.loc)
    location.visible = true
  else
    location.visible = false
  end

  calpopup.visible = not calpopup.visible
end)

-- Hide calpopup when dash closes
dash:connect_signal("setstate::close", function()
  calpopup.visible = false
end)

dash:connect_signal("calpopup::show", function()
  calpopup.screen = awful.screen.focused()
  calpopup.visible = true
end)

dash:connect_signal("calpopup::hide", function() calpopup.visible = false end)

return function() return calpopup end
