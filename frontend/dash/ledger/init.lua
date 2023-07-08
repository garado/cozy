
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

local ui  = require("utils.ui")
local dpi = ui.dpi
local btn    = require("frontend.widget.button")
local wibox  = require("wibox")
local header = require("frontend.widget.dash.header")

-- Modules
local overview = require(... .. ".overview")
local budget   = require(... .. ".budget")
local transactions = require(... .. ".transactions")

local content = wibox.widget({
  {
    overview,
    widget = wibox.container.place,
  },
  {
    budget,
    transactions,
    layout = wibox.layout.fixed.horizontal,
  },
  layout = wibox.layout.fixed.vertical,
})

-------------------------

local action_refresh = btn({
  text = "Refresh",
  func = function()
  end,
})

local ledger_header = header({ title_text = "Ledger" })
ledger_header:add_action(action_refresh)

local container = wibox.widget({
  ledger_header,
  content,
  layout = wibox.layout.ratio.vertical,
})
container:adjust_ratio(1, 0, 0.08, 0.92)

return function()
  return wibox.widget({
    container,
    forced_height = dpi(2000),
    forced_width  = dpi(2000),
    layout = wibox.layout.fixed.horizontal,
  }), false
end
