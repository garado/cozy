
-- █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀ 
-- ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local header = require("frontend.widget.dash.header")

local theme = require(... .. ".theme")
local content = theme

-------------------------

local settings_header = header({
  title_text = "Settings",
})

settings_header:add_sb("Theme")

local container = wibox.widget({
  settings_header,
  {
    content,
    margins = dpi(15),
    widget = wibox.container.margin,
  },
  forced_width  = dpi(2000),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
