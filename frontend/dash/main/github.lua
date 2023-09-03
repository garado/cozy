
-- █▀▀ █ ▀█▀ █░█ █░█ █▄▄    █▀▀ █▀█ █▄░█ ▀█▀ █▀█ █ █▄▄ █▀ 
-- █▄█ █ ░█░ █▀█ █▄█ █▄█    █▄▄ █▄█ █░▀█ ░█░ █▀▄ █ █▄█ ▄█ 

-- Original source:
-- https://github.com/streetturtle/awesome-wm-widgets/blob/master/github-contributions-widget/github-contributions-widget.lua

-- Modified to play nicer with Cozy and also to be an imagebox. It only actually draws the
-- widget once on AwesomeWM startup. I noticed that opening the dash is significantly faster that way.

-- For best results, set up a cronjob to run the script to cache the data once daily.
-- Script path: utils/scripts/fetch-github-contribs [username] [number of days]

local ui = require("utils.ui")
local gfs = require("gears.filesystem")
local conf = require("cozyconf")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local strutil = require("utils.string")

local HEATMAP_DATA = gfs.get_cache_dir() .. "github-data-heatmap"
local CONTRIB_COUNT_DATA = gfs.get_cache_dir() .. "github-data-year-totals"
local SVG_CACHE_PATH = gfs.get_cache_dir() .. "github-data-heatmap.svg"

local DAYS_SHOWN    = 120
local BOXES_PER_COL = 5
local SIDELENGTH = ui.dpi(24)
local GAP_SIZE   = ui.dpi(5)
local WIDTH  = SIDELENGTH * (DAYS_SHOWN / BOXES_PER_COL)
local HEIGHT = SIDELENGTH * BOXES_PER_COL

local img = wibox.widget({
  resize = true,
  widget = wibox.widget.imagebox,
})

-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄ 
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀ 

-- Generating the widget, which gets saved as an SVG

local github = wibox.widget({
  reflection = {
    horizontal = true,
    vertical = true,
  },
  widget = wibox.container.mirror
})

local color_of_empty_cells = beautiful.neutral[900]
local colors = {
  [4] = beautiful.primary[400],
  [3] = beautiful.primary[500],
  [2] = beautiful.primary[600],
  [1] = beautiful.primary[700],
  [0] = beautiful.neutral[900],
}

local function get_square(color)
  return wibox.widget {
    fit = function()
      return SIDELENGTH, SIDELENGTH
    end,
    draw = function(_, _, cr, _, _)
      cr:set_source(gears.color(color))
      cr:rectangle(0, 0, SIDELENGTH - GAP_SIZE, SIDELENGTH - GAP_SIZE)
      cr:fill()
    end,
    layout = wibox.widget.base.make_widget
  }
end

local col = { layout = wibox.layout.fixed.vertical }
local row = { layout = wibox.layout.fixed.horizontal }
local day_idx = BOXES_PER_COL - os.date('%w')
for _ = 0, day_idx do
  table.insert(col, get_square(color_of_empty_cells))
end

local update_widget = function(_, stdout, _, _, _)
  for intensity in stdout:gmatch("[^\r\n]+") do
    if day_idx % BOXES_PER_COL == 0 then
      table.insert(row, col)
      col = { layout = wibox.layout.fixed.vertical }
    end
    table.insert(col, get_square(colors[tonumber(intensity)]))
    day_idx = day_idx + 1
  end
  github:setup({
    row,
    layout = wibox.container.margin
  })
end

local contrib_count = ui.textbox({
  text = "2351",
  align = "center",
  font = beautiful.font_reg_l,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function process_data(stdout)
  -- Script outputs heatmap data and total contrib data to stdout, and these
  -- two are separated by a '=' on a newline
  local data = strutil.split(stdout, "=")

  -- SVG
  update_widget(github, data[1])
  wibox.widget.draw_to_svg_file(github, SVG_CACHE_PATH, WIDTH, HEIGHT)
  img.image = gears.surface.load_uncached(SVG_CACHE_PATH)

  -- Contrib count
  local total = 0
  local lines = strutil.split(data[2], "\r\n")
  for i = 1, #lines do
    total = total + tonumber(lines[i])
  end
  contrib_count:update_text(total)
end

-- If cache files don't exist, run script to populate them.
-- Otherwise read cache files like normal.
-- (The script writes to both cache files and stdout.)
if not gfs.file_readable(HEATMAP_DATA) or not gfs.file_readable(CONTRIB_COUNT_DATA) then
  local cmd = "utils/scripts/fetch-github-contribs " .. conf.github_username .. ' ' .. DAYS_SHOWN
  awful.spawn.easy_async_with_shell(cmd, process_data)
else
  local cmd = "cat " .. HEATMAP_DATA .. " ; echo '=' ; cat " .. CONTRIB_COUNT_DATA
  awful.spawn.easy_async_with_shell(cmd, process_data)
end

return ui.dashbox_v2(
  wibox.widget({
    {
      contrib_count,
      ui.textbox({
        text = "total lifetime contributions",
        color = beautiful.neutral[400],
        align = "center",
      }),
      spacing = ui.dpi(4),
      layout = wibox.layout.fixed.vertical,
    },
    {
      img,
      widget = wibox.container.place,
    },
    spacing = ui.dpi(10),
    layout = wibox.layout.fixed.vertical,
  })
)
