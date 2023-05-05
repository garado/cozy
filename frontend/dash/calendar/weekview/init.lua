
-- █░█░█ █▀▀ █▀▀ █▄▀ █░█ █ █▀▀ █░█░█ 
-- ▀▄▀▄▀ ██▄ ██▄ █░█ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Fancy little weekly schedule viewer!

-- The first widget that gets drawn is the one containing the background
-- gridlines that separate hours and days. This is a custom widget that
-- directly uses Cairo. The height and width of this widget are used to 
-- create a coordinate system for everything else, so once that information
-- is available (the first time the gridlines get drawn), a signal is sent
-- to all the other widgets to start drawing.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local cal   = require("backend.system.calendar")
local mathutils = require("utils.math")

local eventbox = require(... .. ".eventbox")
local nowline = require(... .. ".nowline")
local gridlines = require(... .. ".gridlines")
local hourlabels, daylabels = require(... .. ".labels")()

local SECONDS_IN_WEEK = 24 * 60 * 60 * 7

local background = wibox.widget({
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
background.children[2]:adjust_ratio(1, 0, 0.08, 0.92)

-- Adjust hourlabels + { daylabels, gridlines }
background:adjust_ratio(1, 0, 0.05, 0.95)

local content = wibox.widget({
  background,
  layout = wibox.layout.stack,
})

return function(calheader)
  -- Update calheader with information for weekview tab
  cal:connect_signal("tab::set", function(_, tabname)
    if tabname ~= "weekview" then return end

    local function update_calheader_titles()
      local ts = os.time() + cal.weekview_cur_offset

      calheader:update_title({
        markup = ui.colorize(os.date("%B ", ts), beautiful.fg) ..
                 ui.colorize(os.date("%Y", ts), beautiful.neutral[300])
      })

      -- Calculate week number from day of year.
      local week_num = mathutils.round(os.date("*t", ts).yday / 7)
      calheader:update_subtitle({
        markup = ui.colorize("Week " .. week_num, beautiful.fg)
      })
    end

    update_calheader_titles()
    cal:connect_signal("weekview::change_week", update_calheader_titles)

    calheader:clear_actions()

    calheader:add_action(btn({
      text = "Refresh",
      func = function()
        cal:update_cache()
      end,
    }))

    calheader:add_action(btn({
      text = "Today",
      func = function()
        if cal.weekview_cur_offset == 0 then return end
        cal.weekview_cur_offset = 0
        cal:emit_signal("weekview::change_week")
      end,
    }))

    calheader:add_action(btn({
      text = "&lt;",
      func = function()
        cal.weekview_cur_offset = cal.weekview_cur_offset + (SECONDS_IN_WEEK * -1)
        cal:emit_signal("weekview::change_week")
      end,
    }))

    calheader:add_action(btn({
      text = ">",
      func = function()
        cal.weekview_cur_offset = cal.weekview_cur_offset + (SECONDS_IN_WEEK)
        cal:emit_signal("weekview::change_week")
      end,
    }))
  end)

  return content
end
