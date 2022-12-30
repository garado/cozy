
-- ▀█▀ ▄▀█ █▀ █▄▀ █░░ █ █▀ ▀█▀    █░█ █ 
-- ░█░ █▀█ ▄█ █░█ █▄▄ █ ▄█ ░█░    █▄█ █ 

local gobject = require("gears.object")
local gtable  = require("gears.table")
local beautiful   = require("beautiful")
local wibox       = require("wibox")
local xresources  = require("beautiful.xresources")
local gears       = require("gears")
local colorize    = require("helpers.ui").colorize_text
local remove_pango    = require("helpers.dash").remove_pango
local format_due_date = require("helpers.dash").format_due_date
local dpi   = xresources.apply_dpi
local task  = require("core.system.task")

local debug   = require("core.debug")
-- debug:off()

local tasklist = { }
local instance = nil

tasklist = wibox.widget({
  spacing = dpi(8),
  layout = wibox.layout.flex.vertical,
})

-- Maximum and handle_width are set later
local scrollbar = wibox.widget({
  {
    id            = "bar",
    value         = 0,
    forced_height = dpi(5), -- since it's rotated, this is width
    bar_color     = beautiful.task_scrollbar_bg,
    handle_color  = beautiful.task_scrollbar_fg,
    bar_shape     = gears.shape.rounded_rect,
    widget        = wibox.widget.slider,
  },
  direction = "west",
  widget    = wibox.container.rotate,
})

local scrollbar_cont = wibox.widget({
  scrollbar,
  right   = dpi(15),
  visible = total_overflow() > 0,
  widget  = wibox.container.margin,
})

local tasklist_widget = wibox.widget({
  {
    scrollbar_cont,
    tasklist,
    layout = wibox.layout.align.horizontal,
  },
  height = MAX_TASKLIST_HEIGHT,
  widget = wibox.container.constraint,
})




local function new()
  local ret = gobject{}
  gtable.crush(ret, tasklist, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
