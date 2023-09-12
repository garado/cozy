
-- ▄▀█ █▀▄ █▀▄    ▄█▄    █▀▀ █▀▄ █ ▀█▀    █▀▀ █░█ █▀▀ █▄░█ ▀█▀ █▀ 
-- █▀█ █▄▀ █▄▀    ░▀░    ██▄ █▄▀ █ ░█░    ██▄ ▀▄▀ ██▄ █░▀█ ░█░ ▄█ 

-- A popup allowing you to add and modify events. Uses a modified version
-- of awful.prompt.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local dash  = require("backend.cozy.dash")
local btn   = require("frontend.widget.button")
local calendar = require("backend.system.calendar")
local calprompt = require("frontend.dash.calendar.popups.multiprompt")

local CAL_ICON = ""

-- █░█ █
-- █▄█ █

--- @function gen_textbox_container
-- @brief Generate a fancy looking container widget
--        Definitely doin some fuckery here to get it to look how I want lol
local function gen_textbox_container(header)
  local textbox = wibox.widget({
    {
      text = "",
      widget = wibox.widget.textbox
    },
    fg = beautiful.neutral[300],
    widget = wibox.container.background,
  })
  textbox.widget:set_font(beautiful.font_reg_s)

  -- Wrap textbox inside margin + bg
  local inner_textbox = wibox.widget({
    {
      textbox,
      left = dpi(15),
      top = dpi(10),
      bottom = dpi(4),
      widget = wibox.container.margin,
    },
    bg = beautiful.neutral[800],
    shape = ui.rrect(dpi(4)),
    forced_height = dpi(40),
    widget = wibox.container.background,
  })

  -- Apply rounded rect border to the above
  local rrborder = wibox.widget({
    {
      inner_textbox,
      margins = dpi(2),
      widget = wibox.container.margin,
    },
    bg = beautiful.neutral[500],
    shape = ui.rrect(dpi(4)),
    widget = wibox.container.background,
  })

  -- Stack header textbox with a bg the same color as the popup bg
  local widget = wibox.widget({
    rrborder,
    {
      ui.textbox({
        text = "  "..header.."  ",
        font = beautiful.font_bold_s,
        bg = beautiful.neutral[800],
      }),
      top = dpi(-35),
      left = dpi(10),
      widget = wibox.container.margin,
    },
    layout = wibox.layout.stack,
  })

  function widget:set_active()
    textbox:set_fg(beautiful.neutral[100])
    rrborder.bg = beautiful.primary[400]
  end

  function widget:set_inactive()
    textbox:set_fg(beautiful.neutral[300])
    rrborder.bg = beautiful.neutral[500]
  end

  function widget:clear()
    textbox.widget.text = ""
  end

  widget.tb = textbox.widget

  return widget
end

local header = ui.textbox({
  text = CAL_ICON .. " Add an event",
  font = beautiful.font_reg_l,
})

local title = gen_textbox_container("Title")
local date  = gen_textbox_container("Date")
local stime = gen_textbox_container("Start")
local etime = gen_textbox_container("End/Duration")
local place = gen_textbox_container("Place")

local confirm = btn({
  text = "Confirm",
  bg = beautiful.neutral[600],
  on_release = function() end
})

local widget = wibox.widget({
  header,
  title,
  date,
  {
    stime,
    etime,
    spacing = dpi(15),
    layout = wibox.layout.flex.horizontal,
  },
  place,
  confirm,
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

local cal_add = awful.popup({
  type = "splash",
  minimum_height = dpi(200),
  minimum_width  = dpi(370),
  maximum_width  = dpi(370),
  placement = awful.placement.centered,
  shape = ui.rrect(),
  ontop   = true,
  visible = false,
  widget  = wibox.widget({
    {
      widget,
      margins = dpi(30),
      widget  = wibox.container.margin,
    },
    bg = beautiful.neutral[800],
    widget = wibox.container.background,
  })
})


-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

local textboxes = { title, date, stime, etime, place }
local tbox_idx = 1

local show, hide

--- @function show
-- @brief Show the add/modify popup and start the prompt.
show = function()
  tbox_idx = 1
  textboxes[tbox_idx]:set_active()

  if calendar.modify_mode and calendar.active_element then
    header:update_text(CAL_ICON .. " Modify event")
    local event = calendar.active_element.event
    date.tb.text  = event.s_date
    title.tb.text = event.title
    stime.tb.text = event.s_time
    etime.tb.text = event.e_time
    place.tb.text = event.loc or ""
  else
    header:update_text(CAL_ICON .. " Add event")
    for i = 1, #textboxes do textboxes[i]:clear() end
  end

  calprompt.set_textbox(textboxes[tbox_idx].tb)
  cal_add.visible = true

  calprompt.run({
    font = beautiful.font_reg_s,
    textbox = textboxes[tbox_idx].tb,
    fg_cursor = beautiful.neutral[100],
    bg_cursor = beautiful.primary[400],
    exe_callback = function()
      local func = calendar.modify_mode and calendar.modify_event or calendar.add_event
      func(calendar, {
        title = title.tb.text,
        place = place.tb.text,
        date  = date.tb.text,
        start = stime.tb.text,
        duration = etime.tb.text,
      })
      hide()
    end,
    done_callback = hide,
    hooks = {
      {{"Shift"}, "Tab", function()
        textboxes[tbox_idx]:set_inactive()
        tbox_idx = tbox_idx == 1 and #textboxes or tbox_idx - 1
        textboxes[tbox_idx]:set_active()
        calprompt.set_textbox(textboxes[tbox_idx].tb)
      end},
      {{}, "Tab", function()
        textboxes[tbox_idx]:set_inactive()
        tbox_idx = tbox_idx == #textboxes and 1 or tbox_idx + 1
        textboxes[tbox_idx]:set_active()
        calprompt.set_textbox(textboxes[tbox_idx].tb)
      end},
    }
  })
end

hide = function()
  cal_add.visible = false
  calendar.modify_mode = false
  textboxes[tbox_idx]:set_inactive()
  tbox_idx = 1
  textboxes[tbox_idx]:set_active()
  calprompt.set_textbox(textboxes[tbox_idx].tb)
end

dash:connect_signal("add::setstate::open", show)
dash:connect_signal("add::setstate::close", hide)
dash:connect_signal("add::setstate::toggle", function()
  if cal_add.visible then hide() else show() end
end)
