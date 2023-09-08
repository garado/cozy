
-- ▀█▀ ▄▀█ █▀▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ █▄█ █▄▄ █ ▄█ ░█░ 

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local ui = require("utils.ui")
local dpi = ui.dpi
local beautiful = require("beautiful")

local taglist

local FG_EMPTY    = beautiful.neutral[700]
local FG_FOCUSED  = beautiful.primary[300]
local FG_OCCUPIED = beautiful.neutral[200]

awesome.connect_signal("theme::reload", function(lut)
  FG_EMPTY    = lut[FG_EMPTY]
  FG_FOCUSED  = lut[FG_FOCUSED]
  FG_OCCUPIED = lut[FG_OCCUPIED]
end)

local IND_EMPTY = wibox.widget({
  {
    forced_height = dpi(3),
    forced_width = dpi(2),
    bg = FG_EMPTY,
    shape = gears.shape.circle,
    widget = wibox.container.background,
  },
  left = dpi(3),
  right = dpi(3),
  widget = wibox.container.margin,
})

local IND_OCCUPIED = wibox.widget({
  {
    forced_height = dpi(6),
    forced_width  = dpi(6),
    bg = FG_OCCUPIED,
    shape = gears.shape.circle,
    widget = wibox.container.background,
  },
  left = dpi(3),
  right = dpi(3),
  widget = wibox.container.margin,
})

local IND_FOCUSED = wibox.widget({
  {
    forced_height = dpi(15),
    forced_width  = dpi(6),
    bg = FG_FOCUSED,
    shape = ui.rrect(dpi(2)),
    widget = wibox.container.background,
  },
  left = dpi(3),
  right = dpi(3),
  widget = wibox.container.margin,
})

awesome.connect_signal("theme::reload", function(lut)
  FG_EMPTY    = lut[FG_EMPTY]
  FG_FOCUSED  = lut[FG_FOCUSED]
  FG_OCCUPIED = lut[FG_OCCUPIED]

  -- Undocumented taglist function 
  -- https://www.reddit.com/r/awesomewm/comments/c6r2co/how_to_force_a_widget_to_update/
  taglist._do_taglist_update()
end)

return function(s)
  -- Mouse + client actions
  local modkey = "Mod4"
  local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
      t:view_only()
    end),
    awful.button({ modkey }, 1, function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
    end),
    awful.button({}, 4, function(t)
      awful.tag.viewnext(t.screen)
    end),
    awful.button({}, 5, function(t)
      awful.tag.viewprev(t.screen)
    end)
  )

  local function update_callback(self, c3, _)
    if c3.selected then
      self:set_widget(IND_FOCUSED)
    elseif #c3:clients() == 0 then
      self:set_widget(IND_EMPTY)
    else
      self:set_widget(IND_OCCUPIED)
    end
  end

  local function create_callback(self, c3, _)
    update_callback(self, c3, _)
  end

  taglist = awful.widget.taglist({
    screen = s,
    filter = awful.widget.taglist.filter.all,
    layout = wibox.layout.flex.horizontal,
    widget_template = {
      create_callback = create_callback,
      update_callback = update_callback,
      forced_width = dpi(10),
      widget = wibox.container.margin,
    },
    buttons = taglist_buttons,
  })

  return taglist
end
