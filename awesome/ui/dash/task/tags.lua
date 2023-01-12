
-- ▀█▀ ▄▀█ █▀▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ █▄█ █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local wheader = require("helpers.ui").create_dash_widget_header
local colorize = require("helpers.ui").colorize_text
local navtext = require("modules.keynav.navitem").Textbox
local navbg = require("modules.keynav.navitem").Background
local area = require("modules.keynav.area")
local task = require("core.system.task")

-- █▄▀ █▀▀ █▄█ █▄░█ ▄▀█ █░█ 
-- █░█ ██▄ ░█░ █░▀█ █▀█ ▀▄▀ 
local nav_tags
nav_tags = area({
  name = "tags",
  keys = {
    ["l"] = function()
      local navigator = nav_tags.nav
      navigator:set_area("tasklist")
    end,
  },
  hl_persist_on_area_switch = true,
})

-- █░█ █ 
-- █▄█ █ 
local tag_list = wibox.widget({
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

local taglist_widget = wibox.widget({
  {
    {
      {
        wheader("Tags"),
        tag_list,
        spacing = dpi(10),
        forced_width = dpi(150),
        fill_space = false,
        layout = wibox.layout.fixed.vertical,
      },
      margins = dpi(10),
      widget = wibox.container.margin,
    },
    widget = wibox.container.place
  },
  forced_width = dpi(270),
  bg = beautiful.dash_widget_bg,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function create_tag_button(tag)
  local tag_wibox = wibox.widget({
    id      = tag,
    markup  = colorize(tag, beautiful.fg),
    align   = "center",
    font    = beautiful.base_small_font,
    widget  = wibox.widget.textbox,
    forced_height = dpi(20),
  })

  local nav_tag = navtext({ widget = tag_wibox })
  function nav_tag:release()
    task:emit_signal("selected::tag", tag)
  end

  return tag_wibox, nav_tag
end

task:connect_signal("taglist::update_all", function()
  tag_list:reset()
  nav_tags:remove_all_items()
  nav_tags:reset()

  local tags = task:get_tags()
  for i = 1, #tags do
    local tag_wibox, nav_tag = create_tag_button(tags[i])
    tag_list:add(tag_wibox)
    nav_tags:append(nav_tag)
  end

  nav_tags.widget = navbg({ widget = taglist_widget })
end)

task:connect_signal("taglist::add", function(_, tag)
  local tag_wibox, tag_nav = create_tag_button(tag)
  tag_list:add(tag_wibox)
  nav_tags:append(tag_nav)
end)

-- TODO fix this
task:connect_signal("taglist::remove", function(_, tag)
  -- local tag_wibox = tag_list.children[1]:get_children_by_id(tag)[1]
end)

return function()
  return taglist_widget, nav_tags
end
