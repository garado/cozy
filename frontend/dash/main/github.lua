
-- █▀▀ █ ▀█▀ █░█ █░█ █▄▄
-- █▄█ █ ░█░ █▀█ █▄█ █▄█

-- Original source:
-- https://github.com/streetturtle/awesome-wm-widgets/blob/master/github-contributions-widget/github-contributions-widget.lua

-- Modified to play nicer with Cozy and also to cach data.
-- For best results, set up a cronjob to run the script to cache the data once daily.
-- Script path: utils/scripts/fetch-github-contribs [username] [number of days]

local ui = require("utils.ui")
local gfs = require("gears.filesystem")
local conf = require("cozyconf")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local function worker()
  local github = wibox.widget {
    reflection = {
      horizontal = true,
      vertical = true,
    },
    widget = wibox.container.mirror
  }

  local color_of_empty_cells = beautiful.neutral[800]
  local colors = {
    [4] = beautiful.primary[500],
    [3] = beautiful.primary[600],
    [2] = beautiful.primary[700],
    [1] = beautiful.primary[800],
    [0] = beautiful.neutral[700],
  }

  local function get_square(color)
    local SIDELENGTH = ui.dpi(8.2)
    return wibox.widget {
      fit = function()
        return SIDELENGTH, SIDELENGTH
      end,
      draw = function(_, _, cr, _, _)
        cr:set_source(gears.color(color))
        cr:rectangle(0, 0, ui.dpi(SIDELENGTH - 1), ui.dpi(SIDELENGTH - 1))
        cr:fill()
      end,
      layout = wibox.widget.base.make_widget
    }
  end

  local col = { layout = wibox.layout.fixed.vertical }
  local row = { layout = wibox.layout.fixed.horizontal }
  local day_idx = 5 - os.date('%w')
  for _ = 0, day_idx do
    table.insert(col, get_square(color_of_empty_cells))
  end

  local update_widget = function(_, stdout, _, _, _)
    for intensity in stdout:gmatch("[^\r\n]+") do
      if day_idx % 7 == 0 then
        table.insert(row, col)
        col = { layout = wibox.layout.fixed.vertical }
      end
      table.insert(col, get_square(colors[tonumber(intensity)]))
      day_idx = day_idx + 1
    end
    github:setup(
      {
        row,
        layout = wibox.container.margin
      }
    )
  end

  local CACHEFILE = gfs.get_cache_dir() .. "github"
  local DAYS = 180

  -- If cache file doesn't exist, run script to populate it.
  -- Otherwise read from cache file like normal.
  if not gfs.file_readable(CACHEFILE) then
    local cmd = "utils/scripts/fetch-github-contribs " .. conf.github_username .. ' ' .. DAYS
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      update_widget(github, stdout)
    end)
  else
    local cmd = "cat " .. CACHEFILE
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      update_widget(github, stdout)
    end)
  end

  return github
end

return ui.dashbox_v2(worker())
