
-- █▀▀ █▀█ ▄▀█ █▀█ █░█ 
-- █▄█ █▀▄ █▀█ █▀▀ █▀█ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local ledger = require("backend.system.ledger")
local lgraph = require(... .. ".linegraph")

local content

local graph = lgraph({
  min_value = 0,
  max_value = 0,
  colors = { beautiful.primary[700] },
  avg_color = beautiful.neutral[600],
  forced_height = dpi(100),
})

ledger:balances_this_year()
ledger:connect_signal("ready::year_data", function(_, data)
  if #data == 0 then return end
  content:remove(2)
  content:add(graph)
  local sum = 0
  for i = #data, 1, -1 do
    local d = tonumber(data[i])
    graph:add_data({ d })
    sum = sum + d
  end
end)

local header = ui.textbox({
  text  = "Balance this year",
  align = "center",
  font  = beautiful.font_med_m,
})

content = wibox.widget({
  header,
  ui.placeholder("No balance to show. You're either broke or this isn't configured properly."),
  layout = wibox.layout.fixed.vertical,
})

return ui.dashbox(
  wibox.container.place(content),
  dpi(500), -- width
  dpi(500)  -- height
)
