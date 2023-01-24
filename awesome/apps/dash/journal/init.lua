
-- ░░█ █▀█ █░█ █▀█ █▄░█ ▄▀█ █░░ 
-- █▄█ █▄█ █▄█ █▀▄ █░▀█ █▀█ █▄▄ 

-- Integrated with jrnl
-- https://github.com/jrnl-org/jrnl

local wibox = require("wibox")
local area  = require("modules.keynav.area")
local beautiful = require("beautiful")
local colorize  = require("helpers").ui.colorize_text
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local journal = require("core.system.journal")

-- Import modules
local lock_ui  = require(... .. ".lock")
local contents = require(... .. ".contents")()
local tags, nav_tags           = require(... .. ".tags")()
local entrylist, nav_entrylist = require(... .. ".entrylist")()
local actions, nav_actions     = require(... .. ".actions")()

local nav_journal = area:new({
  name = "journal",
  children = {
    nav_actions,
    nav_entrylist,
    nav_tags,
  },
  keys = {
    ["Escape"] = function()
      journal:emit_signal("ready::entries")
    end
  }
})

-- █░█ █ 
-- █▄█ █ 

local sidebar = wibox.widget({
  {
    markup = colorize("Journal", beautiful.fg),
    font   = beautiful.alt_large_font,
    align  = "center",
    valign = "center",
    widget = wibox.widget.textbox,
  },
  actions,
  entrylist,
  tags,
  spacing       = dpi(15),
  forced_width  = dpi(375),
  layout        = wibox.layout.fixed.vertical,
})

local unlock_ui = wibox.widget({
  { -- needs its own layoutbox to fix strange layout issues
    sidebar,
    layout = wibox.layout.fixed.vertical,
  },
  contents,
  spacing = dpi(15),
  layout  = wibox.layout.fixed.horizontal,
})

local ui = wibox.widget({
  lock_ui,
  layout = wibox.layout.fixed.vertical,
  -----
  update = function(self, widget)
    self:set(1, widget)
  end
})

local widget = wibox.widget({
  {
    ui,
    margins = dpi(15),
    widget  = wibox.container.margin,
  },
  widget = wibox.container.place,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

journal:connect_signal("lock", function()
  journal.is_locked = true
  ui:update(lock_ui)
end)

journal:connect_signal("unlock", function()
  ui:update(unlock_ui)
end)

return function()
  return widget, nav_journal
end
