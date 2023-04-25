
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi   = require("utils.ui").dpi
local beautiful = require("beautiful")
local dashstate = require("backend.state.dash")
local keynav    = require("modules.keynav")
local colorize  = require("utils.ui").colorize
local config    = require("cozyconf")

local profile = require(... .. ".profile")
local github  = require(... .. ".github")

local grid = wibox.widget({
  spacing = 5,
  forced_num_rows = 6,
  forced_num_cols = 6,
  layout = wibox.layout.grid,
})

-- :add_widget_at (child, row, col, row_span, col_span)
grid:add_widget_at(profile, 1, 1, 3, 3)
grid:add_widget_at(github,  4, 4, 3, 3)

return function()
  return grid, false
end
