
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local dash  = require("backend.state.dash")
local cal   = require("backend.system.calendar")
local sbg   = require("frontend.widget.stateful-button-group")
local btn   = require("frontend.widget.button")

local weekview = require(... .. ".weekview")

local content = weekview

--------

local header = ui.textbox({
  markup = ui.colorize(os.date("%B") .. ' ', beautiful.fg) ..
           ui.colorize(os.date("%Y"), beautiful.neutral[400]),
  align = "left",
  font  = beautiful.font_light_xl,
})

local states = sbg()
states:add_btn("Week")
states:add_btn("List")

local refresh_btn = btn({
  text = "Refresh",
  func = function()
    cal:update_cache()
  end,
})

local actions = wibox.widget({
  refresh_btn,
  spacing = dpi(5),
  layout  = wibox.layout.fixed.horizontal,
})

local container = wibox.widget({
  {
    header,
    nil,
    {
      {
        actions,
        states,
        spacing = dpi(15),
        layout  = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    },
    layout = wibox.layout.align.horizontal,
  },
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.09, 0.91)

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
