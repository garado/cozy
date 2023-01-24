
-- █▄▄ █▀█ █▀█ █▄▀ █▀▄▀█ ▄▀█ █▀█ █▄▀    █░░ █ █▀ ▀█▀ 
-- █▄█ █▄█ █▄█ █░█ █░▀░█ █▀█ █▀▄ █░█    █▄▄ █ ▄█ ░█░ 

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local bmcore   = require("core.cozy.bookmarks")
local keynav   = require("modules.keynav")
local colorize = require("helpers.ui").colorize_text
local vpad = require("helpers.ui").vpad

local nav_list = keynav.area({
  name = "nav_list"
})

local list = wibox.widget({
  spacing = dpi(8),
  layout  = wibox.layout.fixed.vertical,
})

function list:create_link(data)
  if data["subcategory"] then
    list:create_subcategory(data)
    return
  end

  local markwibox = wibox.widget({
    markup = colorize(data["title"], beautiful.fg),
    align  = "start",
    valign = "center",
    font   = beautiful.base_small_font,
    widget = wibox.widget.textbox,
  })

  local navmark = keynav.navitem.textbox({
    widget  = markwibox,
    link    = data["link"],
    release = function(_self)
      local cmd = "xdg-open \"" .. _self.link .. "\""
      awful.spawn.easy_async_with_shell(cmd, function() end)
    end
  })

  return markwibox, navmark
end

function list:create_subcategory(data)
  local subheader = wibox.widget({
    {
      markup = colorize(string.upper(data.subcategory), beautiful.fg),
      font   = beautiful.alt_small_font,
      align  = "start",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    {
      forced_height = dpi(10),
      color  = beautiful.bg_l3,
      widget = wibox.widget.separator,
    },
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
  })
  list:add(subheader)

  local nav_subcat = keynav.area({
    name = data.subcategory,
  })

  local marks = data.bookmarks
  for i = 1, #marks do
    local markwibox, navmark = list:create_link(marks[i])
    list:add(markwibox)
    nav_subcat:append(navmark)
  end

  list:add(vpad(dpi(5)))
  nav_list:append(nav_subcat)
end

bmcore:connect_signal("selected::category", function(_, category)
  list:reset()
  nav_list:reset()

  local marks = bmcore.data[category]
  for i = 1, #marks do
    local markwibox, navmark = list:create_link(marks[i])

    if markwibox and navmark then
      list:add(markwibox)
      nav_list:append(navmark)
    end
  end
end)

return function()
  return list, nav_list
end
