
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Nice little overview pane.

local ui  = require("utils.ui")
local dpi = ui.dpi
local btn    = require("frontend.widget.button")
local wibox  = require("wibox")
local header = require("frontend.widget.dash.header")
local ledger = require("backend.system.ledger")
local keynav = require("modules.keynav")

-- Modules
local overview = require(... .. ".overview")
local budget   = require(... .. ".budget")
local graph    = require(... .. ".graph")
local buckets  = require(... .. ".buckets")
local transactions = require(... .. ".transactions")

-- TODO: Enable if #budget_entries > 7
local quote = wibox.widget({
  nil,
  {
    ui.textbox({
      text = "Watch the pennies and the dollars will take care of themselves.",
    }),
    widget = wibox.container.place,
  },
  nil,
  forced_height = dpi(1000),
  layout = wibox.layout.align.vertical,
})

local content = wibox.widget({
  {
    overview,
    widget = wibox.container.place,
  },
  {
    budget,
    transactions,
    {
      buckets,
      graph,
      layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.fixed.horizontal,
  },
  layout = wibox.layout.fixed.vertical,
})

-- Keybinds setup
local nav_ledger = keynav.area({
  name = "nav_ledger",
  autofocus = true,
  keys = {
    ["r"] = function() ledger:emit_signal("refresh") end
  }
})

-- Load initial data
ledger:emit_signal("refresh")

return function() return content, nav_ledger end
