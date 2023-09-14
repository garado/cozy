
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

-- Nice little overview page.

local ui  = require("utils.ui")
local dpi = ui.dpi
local btn    = require("frontend.widget.button")
local wibox  = require("wibox")
local header = require("frontend.widget.dashheader")
local ledger = require("backend.system.ledger")
local keynav = require("modules.keynav")
local beautiful = require("beautiful")

-- Modules
local overview = require(... .. ".overview")
local budget   = require(... .. ".budget")
local graph    = require(... .. ".graph")
local transactions = require(... .. ".transactions")
local reimbursements = require(... .. ".reimbursements")

-- TODO: Enable if #budget_entries > 7 (just to take up the blank space)
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
      reimbursements,
      graph,
      spacing = beautiful.dash_widget_gap,
      layout = wibox.layout.fixed.vertical,
    },
    spacing = beautiful.dash_widget_gap,
    layout = wibox.layout.fixed.horizontal,
  },
  spacing = beautiful.dash_widget_gap,
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

-----------------

-- Load initial data
ledger:emit_signal("refresh")

-- Set up the rest of this tab's UI
local ledger_header = header({
  title_text = "L e d g e r",
  actions = {
    {
      text = "Open ledger",
      func = function()
      end
    },
    {
      text = "Refresh",
      func = function()
        ledger:emit_signal("refresh")
      end,
    },
  },
})

local container = wibox.widget({
  ledger_header,
  require("frontend.widget.yorha.vbar_container")(content),
  forced_width = dpi(2000),
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }),
 nav_ledger
end
