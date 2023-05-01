
-- █░█░█ █▀▀ █▀▀ █▄▀ █░█ █ █▀▀ █░█░█ 
-- ▀▄▀▄▀ ██▄ ██▄ █░█ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local nowline = require(... .. ".nowline")
local gridlines = require(... .. ".gridlines")
local hourlabels, daylabels = require(... .. ".labels")()

local background = wibox.widget({
  hourlabels,
  {
    daylabels,
    {
      gridlines,
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

return content
