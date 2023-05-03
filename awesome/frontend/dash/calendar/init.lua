
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local dash  = require("backend.state.dash")
local cal   = require("backend.system.calendar")
local btn   = require("frontend.widget.button")
local header = require("frontend.widget.dash-header")

local weekview = require(... .. ".weekview")

local content = weekview

--------

local calheader = header({
  header_markup = ui.colorize(os.date("%B") .. ' ', beautiful.fg) ..
                  ui.colorize(os.date("%Y"), beautiful.neutral[400]),
})

calheader:add_sb("Week")
calheader:add_sb("List")

calheader:add_action(btn({
  text = "Refresh",
  func = function()
    cal:update_cache()
  end,
}))

local container = wibox.widget({
  calheader,
  content,
  spacing = dpi(20),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
