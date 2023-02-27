
-- █▀ █▀▀ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- ▄█ ██▄ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local awful = require("awful")
local wibox = require("wibox")
local ui    = require("helpers.ui")
local bmcore = require("core.cozy.bookmarks")
local bookmarks = require("cozyconf.bookmarks")

bmcore.completion = {}

local function create_header(text, i)
  return wibox.widget({
    font   = beautiful.altfont_reg_m,
    markup = ui.colorize_text(text, beautiful.accents[i]),
    align  = "left",
    widget = wibox.widget.textbox,
  })
end

local function create_single_link(data)
  local icon = wibox.widget({
    forced_width = dpi(20),
    font   = beautiful.altfont_reg_xs,
    text   = data.icon or "",
    align  = "left",
    widget = wibox.widget.textbox,
  })

  local title = wibox.widget({
    font   = beautiful.altfont_reg_s,
    text   = data.title,
    align  = "left",
    widget = wibox.widget.textbox,
  })

  local link = wibox.widget({
    {
      icon,
      fg     = beautiful.fg_0,
      widget = wibox.container.background,
    },
    {
      title,
      fg     = beautiful.fg_0,
      widget = wibox.container.background,
    },
    layout = wibox.layout.fixed.horizontal,
    -----------
    set_fg = function(self, color)
      self.children[1].fg = color
      self.children[2].fg = color
    end
  })

  -- store in data table
  bmcore.data[data.title][bmcore.WIBOX] = link

  return link
end

local function create_links(links)
  local container = wibox.widget({
    spacing = dpi(9),
    layout  = wibox.layout.fixed.vertical,
  })

  for i = 1, #links do
    table.insert(bmcore.completion, links[i].title)
    container:add(create_single_link(links[i]))
  end

  return container
end

local cont = wibox.widget({
  spacing = dpi(60),
  forced_num_rows = 2,
  forced_num_cols = 3,
  layout  = wibox.layout.grid,
})

local i = 1
for k, v in pairs(bookmarks) do
  local header  = create_header(k, i)
  local content = create_links(v)

  local section = wibox.widget({
    header,
    content,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.vertical,
  })

  cont:add(section)
  i = i + 1
end

return cont
