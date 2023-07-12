
-- █▀█ █░█ █▀▀ █▀█ █░█ █ █▀▀ █░█░█ 
-- █▄█ ▀▄▀ ██▄ █▀▄ ▀▄▀ █ ██▄ ▀▄▀▄▀ 

local ui  = require("utils.ui")
local dpi = ui.dpi
local wibox     = require("wibox")
local beautiful = require("beautiful")
local ledger    = require("backend.system.ledger")

-- ▄▀█ █▀▀ █▀▀ █▀█ █░█ █▄░█ ▀█▀ █▀ 
-- █▀█ █▄▄ █▄▄ █▄█ █▄█ █░▀█ ░█░ ▄█ 

local function gen_label(label)
  return ui.textbox({
    text  = label,
    color = beautiful.neutral[200],
  })
end

local function gen_thing(id, color)
  local thing = wibox.widget({
    {
      ui.vpad(dpi(5)),
      ui.textbox({
        text   = "$",
        valign = "top",
        color  = beautiful.neutral[200],
      }),
      layout = wibox.layout.fixed.vertical,
    },
    ui.textbox({
      text  = "0.00",
      font  = beautiful.font_reg_xl,
      color = color or beautiful.neutral[100],
    }),
    spacing = dpi(1),
    layout  = wibox.layout.fixed.horizontal,
  })

  ledger:connect_signal("ready::" .. id, function(_, amount)
    thing.children[2]:update_text(amount)
  end)

  return thing
end

local total = wibox.widget({
  gen_label("Total"),
  gen_thing("total"),
  spacing = dpi(5),
  layout  = wibox.layout.fixed.vertical,
})

local checking = wibox.widget({
  gen_label("Checking"),
  gen_thing("checking"),
  spacing = dpi(5),
  layout  = wibox.layout.fixed.vertical,
})

local savings = wibox.widget({
  gen_label("Savings"),
  gen_thing("savings"),
  spacing = dpi(5),
  layout  = wibox.layout.fixed.vertical,
})

local cash = wibox.widget({
  gen_label("Cash"),
  gen_thing("cash"),
  spacing = dpi(5),
  layout  = wibox.layout.fixed.vertical,
})


-- █ █▄░█ █▀▀ █▀█ █▀▄▀█ █▀▀ ░░▄▀ █▀▀ ▀▄▀ █▀█ █▀▀ █▄░█ █▀ █▀▀ █▀ 
-- █ █░▀█ █▄▄ █▄█ █░▀░█ ██▄ ▄▀░░ ██▄ █░█ █▀▀ ██▄ █░▀█ ▄█ ██▄ ▄█ 

local income = wibox.widget({
  gen_label("Income this month"),
  gen_thing("income", beautiful.green[400]),
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

local expenses = wibox.widget({
  gen_label("Expenses this month"),
  gen_thing("expenses", beautiful.red[400]),
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical,
})

local overview = wibox.widget({
  ui.place(total),
  ui.place(checking),
  ui.place(savings),
  ui.place(cash),
  ui.place(income),
  ui.place(expenses),
  spacing = dpi(10),
  layout  = wibox.layout.flex.horizontal,
})

ledger:connect_signal("refresh", function(self)
  self:parse_assets()
  self:parse_month_income()
  self:parse_month_expenses()
end)

return ui.dashbox(overview, dpi(2000), dpi(100), beautiful.neutral[800])
