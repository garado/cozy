
-- █▀▀ █▄░█ ▀█▀ █▀█ █▄█    █░░ █ █▀ ▀█▀ 
-- ██▄ █░▀█ ░█░ █▀▄ ░█░    █▄▄ █ ▄█ ░█░ 

-- Selectable list of journal entry titles

local wibox   = require("wibox")
local gears   = require("gears")
local area    = require("modules.keynav.area")
local naventry    = require("modules.keynav.navitem").Textbox
local beautiful   = require("beautiful")
local colorize    = require("helpers").ui.colorize_text
local xresources  = require("beautiful.xresources")
local dpi     = xresources.apply_dpi
local journal = require("core.system.journal")

-- Keyboard navigation
local nav_entrylist = area:new({ name = "entrylist" })

-- █░█ █ 
-- █▄█ █ 

local ui_entrylist = wibox.widget({
  spacing = dpi(5),
  layout  = wibox.layout.fixed.vertical,
})

local ui_entrylist_container = wibox.widget({
  {
    ui_entrylist,
    margins = dpi(15),
    widget  = wibox.container.margin,
  },
  shape = gears.shape.rounded_rect,
  bg = beautiful.dash_widget_bg,
  widget = wibox.container.background,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function create_entry_list_item(title, date, index)
  local entry = wibox.widget({
    markup = colorize(title, beautiful.fg),
    align  = "left",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local nav = naventry:new(entry)
  function nav:release()
    journal.entry_index = index
    journal:emit_signal("entry_selected", index)
  end

  local fuckyou = wibox.widget({
    markup = colorize(" - " .. date, beautiful.fg_sub),
    widget = wibox.widget.textbox,
  })

  return wibox.widget({
    entry,
    fuckyou,
    layout = wibox.layout.fixed.horizontal,
  }), nav
end

local function create_entry_list()
  local entry_data = journal.entries
  for i = 1, #entry_data do

    local title = entry_data[i][journal.title]
    local date  = entry_data[i][journal.date]
    local entry, nav = create_entry_list_item(title, date, i)

    ui_entrylist:add(entry)
    nav_entrylist:append(nav)
  end
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

journal:connect_signal("ready::entries", function()
  print('ready::entries caught by entrylist')
  create_entry_list()
end)

return function()
  return ui_entrylist_container, nav_entrylist
end
