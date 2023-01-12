
-- █▀▀ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ ▀█▀ █▀ 
-- █▄▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ ░█░ ▄█ 

-- Textbox showing log entry contents and a scrollbar, as well as a list of tags.

local wibox   = require("wibox")
local gears   = require("gears")
local area    = require("modules.keynav.area")
local naventry    = require("modules.keynav.navitem").Textbox
local beautiful   = require("beautiful")
local colorize    = require("helpers.ui").colorize_text
local xresources  = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local journal = require("core.system.journal")

-- █░█ █ 
-- █▄█ █ 

local title_wibox = wibox.widget({
  font    = beautiful.alt_med_font,
  widget  = wibox.widget.textbox,
})

local datetime_wibox = wibox.widget({
  widget  = wibox.widget.textbox,
})

local contents_wibox = wibox.widget({
  id      = "texbox",
  text    = "placeholder",
  widget  = wibox.widget.textbox,
})

local tag_subheader = wibox.widget({
  markup = colorize("Tags", beautiful.main_accent),
  widget = wibox.widget.textbox,
})

local header_and_contents_container = wibox.widget({
  { -- Header
    title_wibox,
    nil,
    datetime_wibox,
    layout = wibox.layout.align.horizontal,
  },
  contents_wibox,
  { -- Separator
    {
      color = beautiful.bg_l3,
      forced_height = dpi(5),
      widget = wibox.widget.separator,
    },
    bottom = dpi(5),
    widget = wibox.container.margin,
  },
  { -- Tags
    tag_subheader,
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
  visible = false,
})

local contents_container = wibox.widget({
  {
    header_and_contents_container,
    margins = dpi(15),
    widget  = wibox.container.margin,
  },
  forced_width = dpi(1000),
  bg      = beautiful.dash_widget_bg,
  shape   = gears.shape.rounded_rect,
  widget  = wibox.container.background,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function update_contents(title, date, time, stdout)
  local markup
  markup = colorize(title, beautiful.main_accent)
  title_wibox:set_markup_silently(markup)

  markup = colorize(time .. " " .. date, beautiful.main_accent)
  datetime_wibox:set_markup_silently(markup)

  contents_wibox:set_markup_silently(colorize(stdout, beautiful.fg))
end

journal:connect_signal("lock", function()
  header_and_contents_container.visible = false
end)

journal:connect_signal("ready::entry_contents", function(_, index, stdout)
  local entry = journal:get_entry(index)
  local title = entry[journal.title]
  local date  = entry[journal.date]
  local time  = entry[journal.time]
  update_contents(title, date, time, stdout)
  header_and_contents_container.visible = true
end)

return function()
  return contents_container
end
