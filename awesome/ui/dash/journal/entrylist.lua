
-- █▀▀ █▄░█ ▀█▀ █▀█ █▄█    █░░ █ █▀ ▀█▀ 
-- ██▄ █░▀█ ░█░ █▀▄ ░█░    █▄▄ █ ▄█ ░█░ 

-- Selectable list of journal entry titles

local wibox   = require("wibox")
local box     = require("helpers.ui").create_boxed_widget
local keynav  = require("modules.keynav")
local navtext = keynav.navitem.textbox
local beautiful   = require("beautiful")
local xresources  = require("beautiful.xresources")
local colorize    = require("helpers").ui.colorize_text
local dpi     = xresources.apply_dpi
local journal = require("core.system.journal")

-- Keyboard navigation
local nav_entrylist = keynav.area({ name = "entrylist" })

-- █░█ █ 
-- █▄█ █ 

local ui_header = wibox.widget({
  markup = colorize("Entries", beautiful.fg),
  align  = "center",
  valign = "center",
  font   = beautiful.alt_med_font,
  widget = wibox.widget.textbox,
  ----
  update = function(self, tag)
    local text = "Entries"
    if tag then
      text = text .. " tagged '" .. tag .. "'"
    end
    self:set_markup_silently(colorize(text, beautiful.fg))
  end,
})

local ui_entrylist = wibox.widget({
  ui_header,
  spacing = dpi(6),
  layout  = wibox.layout.fixed.vertical,
  -----
  _reset = function(self)
    self:reset()
    self:add(ui_header)
  end
})

local ui_entrylist_container = box(
  wibox.widget({
    ui_entrylist,
    margins = dpi(3),
    widget = wibox.container.margin,
  }), nil, nil, beautiful.dash_widget_bg)

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function create_entry_list_item(title, date, index)
  local entry = wibox.widget({
    markup = colorize(date .. " " .. title, beautiful.fg),
    align  = "left",
    valign = "center",
    ellipsize = "right",
    forced_width = dpi(200),
    widget = wibox.widget.textbox,
  })

  local naventry = navtext({
    widget = entry,
    release = function()
      journal.entry_index = index
      journal:emit_signal("entry_selected", index)
    end
  })

  return entry, naventry
end

local function create_entry_list(tag)
  ui_entrylist:_reset()
  nav_entrylist:remove_all_items()
  nav_entrylist:reset()

  local entry_data = tag and journal.tagged[tag] or journal.entries

  for i = #entry_data, 1, -1 do
    local title = entry_data[i][journal.title]
    local date  = entry_data[i][journal.date]
    local entry, nav = create_entry_list_item(title, date, i)

    ui_entrylist:add(entry)
    nav_entrylist:append(nav)
  end
end

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

journal:connect_signal("ready::entries", function(_, tag)
  create_entry_list(tag)
  ui_header:update(tag)
end)

nav_entrylist.widget = keynav.navitem.background({ widget = ui_entrylist_container.children[1] })

return function()
  return ui_entrylist_container, nav_entrylist
end
