
-- █▀▄▀█ █▀█ █▄░█ ▀█▀ █░█ █░░ █▄█ 
-- █░▀░█ █▄█ █░▀█ ░█░ █▀█ █▄▄ ░█░ 
--
-- █▄▄ █░█ █▀▄ █▀▀ █▀▀ ▀█▀
-- █▄█ █▄█ █▄▀ █▄█ ██▄ ░█░

-- Integrated with ledger:
-- https://github.com/ledger/

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")
local naughty = require("naughty")
local user_vars = require("user_variables")

local string = string
local tonumber = tonumber
local table = table
local ledger_file = user_vars.ledger.ledger_file
local budget_file = user_vars.ledger.budget_file

-- graph colors
local color_palette = beautiful.arcchart_colors

local function create_graph()

  -- obtain data
  local files = " -f " .. ledger_file .. " -f " .. budget_file .. " "
  local cmd = "ledger " .. files .. "--budget --monthly register expenses"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local lines = { }
    -- iterate lines
    for str in stdout:gmatch("[^\r\n]+") do
      -- iterate fields (whitespace-separated)
      -- if separating on whitespaces, there are 6 fields per line
      -- the first 3 are dates (and a hypen),
      -- and the last 3 are:
      --    category
      --    amt spent - amt budgeted for category
      --    total budget thingy
      -- i care about the 4th and 5th
      local num_entries = 0
      local i,v = string.find(str, "%$")
      local val = string.sub(str, i)
    end
  end)

  local graph = wibox.widget({
    max_value = 100,
    group_colors = color_palette,
    step_width = dpi(20),
    stack = true,
    step_shape = gears.shape.rect,
    capacity = 2,
    widget = wibox.widget.graph,
    background_color = beautiful.dash_widget_bg,
  })

  return wibox.widget({
    graph,
    layout = wibox.layout.fixed.horizontal,
  })
end

return helpers.ui.create_boxed_widget(create_graph(), dpi(300), dpi(300), beautiful.dash_widget_bg)
