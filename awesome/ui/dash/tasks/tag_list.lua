
-- ▀█▀ ▄▀█ █▀▀ █░░ █ █▀ ▀█▀ 
-- ░█░ █▀█ █▄█ █▄▄ █ ▄█ ░█░ 

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local wheader = require("helpers.ui").create_dash_widget_header
local colorize = require("helpers.ui").colorize_text
local tasks_textbox = require("modules.keynav.navitem").Tasks_Textbox
local taskbox = require("modules.keynav.navitem").Taskbox
local Area = require("modules.keynav.area")
local task = require("core.system.task")

-- █▄▀ █▀▀ █▄█ █▄░█ ▄▀█ █░█ 
-- █░█ ██▄ ░█░ █░▀█ █▀█ ▀▄▀ 
local nav_tags
nav_tags = Area:new({
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
    markup  = colorize(tag, beautiful.fg),
    align   = "center",
    font    = beautiful.font_name .. "11",
    widget  = wibox.widget.textbox,
    forced_height = dpi(20),
  })

  local nav_tag = tasks_textbox:new(tag_wibox)
  function nav_tag:release()
    task:set_focused_tag(tag)
    task:set_focused_proj(nil)
    task:emit_signal("selected::tag", tag)
  end

  return tag_wibox, nav_tag
end

task:connect_signal("ready::tags", function()
  local tags = task:get_tags()
  for i = 1, #tags do
    local tag_wibox, nav_tag = create_tag_button(tags[i])
    tag_list:add(tag_wibox)
    nav_tags:append(nav_tag)
  end

  nav_tags.widget = taskbox:new(taglist_widget)
end)

return function()
  return taglist_widget, nav_tags
end
