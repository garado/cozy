
--▀█▀ ▄▀█ █▀▀ █▀ 
--░█░ █▀█ █▄█ ▄█ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local box = require("helpers.ui").create_boxed_widget
local wheader = require("helpers.ui").create_dash_widget_header
local colorize = require("helpers.ui").colorize_text
local keynav = require("modules.keynav")
local task = require("core.system.task")


-- █░█ █ 
-- █▄█ █ 

local tag_list = wibox.widget({
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

local widget = wibox.widget({
  wheader("Tags"),
  tag_list,
  spacing = dpi(10),
  forced_width = dpi(150),
  fill_space = false,
  layout = wibox.layout.fixed.vertical,
})

local container = box(widget, nil, nil, beautiful.dash_widget_bg)

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local nav_tags = keynav.area({
  name   = "nav_tags",
  widget = keynav.navitem.background({ widget = container.children[1] }),
})

local function create_tag_item(tag)
  local tag_wibox = wibox.widget({
    id      = tag,
    markup  = colorize(tag, beautiful.fg),
    align   = "center",
    font    = beautiful.base_small_font,
    widget  = wibox.widget.textbox,
    forced_height = dpi(20),
  })

  local nav_tag = keynav.navitem.textbox({ widget = tag_wibox })
  function nav_tag:release()
    task:emit_signal("selected::tag", tag)
  end

  return tag_wibox, nav_tag
end

task:connect_signal("taglist::update", function()
  tag_list:reset()
  nav_tags:reset()

  for i = 1, #task.tag_names do
    local tag_wibox, nav_tag = create_tag_item(task.tag_names[i])
    tag_list:add(tag_wibox)
    nav_tags:add(nav_tag)
  end
end)

return function()
  return container, nav_tags
end

