
-- █▀ █▀▀ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀ 
-- ▄█ ██▄ █▄▄ ░█░ █ █▄█ █░▀█ ▄█ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local wibox = require("wibox")
local ui    = require("helpers.ui")
local bm = require("core.cozy.bookmarks")
local bookmarks = require("cozyconf.bookmarks")

bm.completion = {}

-- █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀ 
-- █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█ 

local function create_header(text, i)
  return wibox.widget({
    font   = beautiful.altfont_reg_m,
    markup = ui.colorize_text(text, beautiful.accents[i]),
    align  = "left",
    widget = wibox.widget.textbox,
  })
end

local function create_single_link(data)
  local no_icon = data[bm._ICON] == ""

  local icon = wibox.widget({
    forced_width = dpi(20),
    font   = beautiful.altfont_reg_xs,
    text   = not no_icon and data[bm._ICON] or "",
    align  = "left",
    widget = wibox.widget.textbox,
  })

  local title = wibox.widget({
    font   = beautiful.altfont_reg_s,
    text   = data[bm._TITLE] or "untitled",
    align  = "left",
    widget = wibox.widget.textbox,
  })

  -- Wibox containing icon and bookmark title
  local link = wibox.widget({
    {
      {
        icon,
        fg     = beautiful.fg_0,
        widget = wibox.container.background,
      },
      widget = wibox.container.place,
    },
    {
      title,
      fg     = beautiful.fg_0,
      widget = wibox.container.background,
    },
    spacing = dpi(3),
    layout  = wibox.layout.fixed.horizontal,
    -----------
    set_fg = function(self, color)
      self.children[1].children[1].fg = color
      self.children[2].fg = color
    end
  })

  -- Store reference to this wibox directly in the bookmarks config file
  -- Need the wibox reference to change text colors
  data[#data+1] = link -- this should always be index 4

  return link
end

local function create_links(links)
  local container = wibox.widget({
    spacing = dpi(9),
    layout  = wibox.layout.fixed.vertical,
    -----
    set_all_fg = function(self, color)
      for i = 1, #self.children do
        self.children[i]:set_fg(color)
      end
    end
  })

  for i = 1, #links do
    table.insert(bm.completion, links[i].title)
    container:add(create_single_link(links[i]))
  end

  return container
end


-- ▄▀█ █▀ █▀ █▀▀ █▀▄▀█ █▄▄ █░░ █▄█ 
-- █▀█ ▄█ ▄█ ██▄ █░▀░█ █▄█ █▄▄ ░█░ 

local cont = wibox.widget({
  forced_num_rows = 2,
  forced_num_cols = 3,
  spacing = dpi(60),
  layout  = wibox.layout.grid,
  -----
  set_all_fg = function(self, color)
    for i = 1, #self.children do
      local content = self.children[i].children[2]
      for _ = 1, #content.children do
        content:set_all_fg(color)
      end
    end
  end
})

bm.content = cont

-- Iterate through all bookmarks and
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
