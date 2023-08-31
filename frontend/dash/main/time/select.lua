
-- █▀ █▀▀ █░░ █▀▀ █▀▀ ▀█▀    █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ 
-- ▄█ ██▄ █▄▄ ██▄ █▄▄ ░█░    ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ 

local beautiful = require("beautiful")
local cozyconf  = require("cozyconf")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local btn   = require("frontend.widget.button")
local sbtn  = require("frontend.widget.stateful-button")
local dash  = require("backend.cozy.dash")
local ss    = require("frontend.widget.single-select")
local keynav = require("modules.keynav")

local navitems = {}

local select = wibox.widget({
  ui.textbox({
    text  = "Select session",
    align = "center",
    color = beautiful.neutral[300],
  }),
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})

local select_grid = wibox.widget({
  forced_num_cols = 2,
  forced_num_rows = 2,
  spacing = dpi(10),
  layout = wibox.layout.grid,
})
select_grid = ss({ layout = select_grid })

-- Add session options
local opts = cozyconf.timewarrior_sessions
for i = 1, #opts do
  local session_btn = sbtn({
    text  = opts[i],
    deselect = {
      bg    = beautiful.neutral[700],
      bg_mo = beautiful.neutral[600],
    },
    func = function()
      dash:emit_signal("main::time::changestate", "type")
    end
  })

  table.insert(navitems, session_btn)
  select_grid:add_element(session_btn)
end
select:add(select_grid)

local cancel = btn({
  align = "center",
  text  = " Cancel",
  fg    = beautiful.neutral[300],
  func  = function()
    dash:emit_signal("main::time::changestate", "idle")
  end
})

local widget = wibox.widget({
  select,
  {
    cancel,
    widget = wibox.container.place,
  },
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

widget.navitems = navitems
widget.keys = {
  ["BackSpace"] = function() dash:emit_signal("main::time::changestate", "idle") end,
}

return widget
