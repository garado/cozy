
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local btn    = require("frontend.widget.button")
local header = require("frontend.widget.dash.header")
local ledger = require("backend.system.ledger")
local keynav = require("modules.keynav")

-- Forward declaration
local container

-- Import pages
local overview, nav_overview = require(... .. ".overview")()

local content = wibox.widget({
  overview,
  widget = wibox.container.margin,
})

-- Set up the rest of this tab's UI
local ledger_header = header({
  title_text = "Ledger",
  actions = {
    {
      text = "Refresh",
      func = function()
        ledger:emit_signal("refresh")
      end,
    },
  },
})

container = wibox.widget({
  ledger_header,
  content,
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
