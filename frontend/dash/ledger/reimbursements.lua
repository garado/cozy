
-- █▀█ █▀▀ █ █▀▄▀█ █▄▄ █░█ █▀█ █▀ █▀▀ █▀▄▀█ █▀▀ █▄░█ ▀█▀ █▀
-- █▀▄ ██▄ █ █░▀░█ █▄█ █▄█ █▀▄ ▄█ ██▄ █░▀░█ ██▄ █░▀█ ░█░ ▄█

local beautiful = require("beautiful")
local ui = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local ledger = require("backend.system.ledger")
local gears = require("gears")

--- @function gen_entry
-- @brief Generate a reimbursement entry widget
local function gen_entry(data)
  local amt = tonumber(data[1])
  local text
  if amt > 0 then
    text = data[2] .. " owes you $" .. amt
  else
    text = "You owe " .. data[2] .. " $" .. amt
  end

  local widget = wibox.widget({
    {
      {
        ui.textbox({
          text = data[2]:sub(1, 1),
          font = beautiful.font_med_s,
          align = "center",
          color = beautiful.primary[700],
        }),
        margins = dpi(8),
        widget = wibox.container.margin,
      },
      shape = gears.shape.circle,
      bg = beautiful.primary[100],
      widget = wibox.container.background,
    },
    ui.textbox({
      text = text,
    }),
    spacing = dpi(12),
    layout = wibox.layout.fixed.horizontal,
  })

  return widget
end

local content = wibox.widget({
  nil,
  {
    ui.textbox({
      text = "$",
      align = "center",
      color = beautiful.neutral[300],
      font = beautiful.font_bold_xxl,
    }),
    ui.textbox({
      text = "No reimbursements.",
      align = "center",
      color = beautiful.neutral[300],
    }),
    layout = wibox.layout.fixed.vertical,
  },
  nil,
  forced_height = dpi(400),
  spacing = dpi(8),
  layout = wibox.layout.fixed.vertical,
})

local reimbursements = wibox.widget({
  ui.textbox({
    text   = "Reimbursements & Liabilities",
    align  = "center",
    height = dpi(30),
    font   = beautiful.font_med_m,
  }),
  content,
  forced_height = dpi(300),
  layout = wibox.layout.fixed.vertical,
})

ledger:connect_signal("refresh", function()
  ledger:parse_reimbursements()
end)

ledger:connect_signal("ready::reimbursements", function(_, data)
  if #data == 0 then return end
  content:reset()
  for i = 1, #data do
    local w = gen_entry(data[i])
    content:add(w)
  end
  ledger:parse_reimbursement_data()
end)

ledger:connect_signal("ready::reimbursement_data", function()
end)

return ui.dashbox(reimbursements)
