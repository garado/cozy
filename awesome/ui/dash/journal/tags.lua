
-- ▀█▀ ▄▀█ █▀▀ █▀ 
-- ░█░ █▀█ █▄█ ▄█ 

local wibox   = require("wibox")
local keynav      = require("modules.keynav")
local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local colorize    = require("helpers.ui").colorize_text
local box     = require("helpers.ui").create_boxed_widget
local dpi     = xresources.apply_dpi
local journal     = require("core.system.journal")

local nav_tags = keynav.area({ name = "nav_tags" })

local taglist = wibox.widget({
  spacing = dpi(6),
  layout  = wibox.layout.fixed.vertical,
})

local widget = wibox.widget({
  {
    markup = colorize("Tags", beautiful.fg),
    align  = "center",
    valign = "center",
    font   = beautiful.alt_large_font,
    widget = wibox.widget.textbox,
  },
  {
    taglist,
    widget = wibox.container.place,
  },
  spacing = dpi(5),
  layout  = wibox.layout.fixed.vertical,
})

local container = box(widget, dpi(0), dpi(1000), beautiful.dash_widget_bg)

local function create_tag(tag, count)
  local counttext = '(' .. count .. ')'
  local tagbox = wibox.widget({
    markup = colorize(tag .. ' ' .. counttext, beautiful.fg),
    align  = "center",
    valign = "center",
    font   = beautiful.base_small_font,
    widget = wibox.widget.textbox,
  })

  local nav_tag = keynav.navitem.textbox({
    widget  = tagbox,
    tag     = tag,
    release = function(self)
      journal:parse_entries_with_tag(self.tag)
    end
  })

  return tagbox, nav_tag
end


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

journal:connect_signal("ready::tags", function()
  nav_tags:remove_all_items()
  nav_tags:reset()
  taglist:reset()

  for i = 1, #journal.tags do
    local tagbox, nav_tag = create_tag(journal.tags[i][1], journal.tags[i][2])
    taglist:add(tagbox)
    nav_tags:append(nav_tag)
  end
end)

nav_tags.widget = keynav.navitem.background({ widget = container.children[1] })

return function()
  return container, nav_tags
end
