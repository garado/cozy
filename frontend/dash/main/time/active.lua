
-- ▄▀█ █▀▀ ▀█▀ █ █░█ █▀▀ 
-- █▀█ █▄▄ ░█░ █ ▀▄▀ ██▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local timew = require("backend.system.time")
local dash  = require("backend.cozy").dash
local strutil = require("utils.string")
local math = math

local session_tag = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "Focus",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  ui.textbox({
    text = "Cozy:General",
    align = "center",
    font  = beautiful.font_reg_m,
  }),
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
  ----
  update = function(self, time)
    self.children[2]:update_text(time)
  end
})

local session_annotation = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "Task",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  {
    {
      {
        ui.textbox({
          text  = "[Feat] Change sort option (alphabetical/duedate+alpha)",
          align = "center",
          font  = beautiful.font_reg_s,
        }),
        step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
        speed  = 100,
        fps    = 40,
        layout = wibox.container.scroll.horizontal,
      },
      left  = dpi(25),
      right = dpi(25),
      widget = wibox.container.margin,
    },
    widget = wibox.container.place,
  },
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
  ---
  update = function(self, text)
    self.children[2].widget.widget.widget:update_text(text)
  end
})

local session_time = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "This Session",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  ui.textbox({
    text  = "42m",
    align = "center",
    font  = beautiful.font_reg_m,
  }),
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
  ---
  update = function(self)
    local start_ts = strutil.dt_convert(timew.tracking.start, strutil.dt_format.iso)
    local elapsed = (os.time() - start_ts) / 60
    local text = ""
    local tmp = 0

    tmp = math.floor(elapsed % 60)
    text = tmp .. "m"
    elapsed = math.floor(elapsed - tmp)

    if elapsed > 0 then
      tmp = math.floor(elapsed % 60)
      text = tmp .. "h " .. text
      elapsed = elapsed - tmp
    end

    self.children[2]:update_text(text)
  end
})

local total_today = wibox.widget({
  ui.textbox({
    align = "center",
    text  = "Total Today",
    font  = beautiful.font_med_s,
    color = beautiful.neutral[400],
  }),
  ui.textbox({
    text = "2h 55m",
    align = "center",
    font  = beautiful.font_reg_m,
  }),
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
  ---
  update = function(self, text)
    self.children[2]:update_text(text)
  end
})

local stop = btn({
  text  = "Stop",
  bg    = beautiful.neutral[700],
  bg_mo = beautiful.neutral[600],
  width = dpi(100),
  on_release = function()
    timew:set_tracking_inactive()
  end
})

local active = wibox.widget({
  session_tag,
  session_annotation,
  {
    {
      session_time,
      total_today,
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  },
  {
    stop,
    widget = wibox.container.place,
  },
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█

local function stats_update()
  timew:fetch_stats_today()
  session_time:update()
  session_tag:update(timew.tracking.tags[1])
  session_annotation:update(timew.tracking.annotation)
end
stats_update()

timew:connect_signal("tracking::active", function()
  session_tag:update(timew.tracking.tags[1])
  session_annotation:update(timew.tracking.annotation)
  dash:connect_signal("setstate::open", stats_update)
end)

timew:connect_signal("tracking::inactive", function()
  dash:disconnect_signal("setstate::open", stats_update)
end)

timew:connect_signal("stats::today::ready", function(_, time)
  total_today:update(time)
end)

return active
