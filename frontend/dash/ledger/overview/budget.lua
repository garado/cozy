
-- █▄▄ █░█ █▀▄ █▀▀ █▀▀ ▀█▀ 
-- █▄█ █▄█ █▄▀ █▄█ ██▄ ░█░ 

local ui  = require("utils.ui")
local dpi = ui.dpi
local beautiful  = require("beautiful")
local wibox = require("wibox")
local ledger = require("backend.system.ledger")

-- @function gen_entry
-- @brief Generates a progress bar showing percent fulfillment of a budget category.
-- @param bdata { category_name, spent, allotted}
local function gen_entry(bdata)
  local cname = bdata[1]
  local spent = bdata[2]
  local allotted = bdata[3]

  local label = ui.textbox({
    text = cname,
    font = beautiful.font_reg_m,
    valign = "end",
  })

  local amounts = ui.textbox({
    text   = "Remaining: " .. (allotted - spent),
    align  = "right",
    valign = "end",
    color  = beautiful.neutral[300],
  })

  local barval = (spent / allotted) * 100
  local bar = wibox.widget({
    color  = beautiful.random_accent_color(),
    background_color = beautiful.neutral[700],
    forced_height = dpi(8),
    value = barval,
    max_value = 100,
    shape  = ui.rrect(),
    widget = wibox.widget.progressbar,
  })

  return wibox.widget({
    {
      label,
      nil,
      amounts,
      layout = wibox.layout.align.horizontal,
    },
    bar,
    spacing = dpi(5),
    forced_width = dpi(250),
    layout = wibox.layout.fixed.vertical,
  })
end

-- Assembly
local budget_entries = wibox.widget({
  spacing = dpi(25),
  layout  = wibox.layout.flex.vertical,
})

local budget = wibox.widget({
  ui.textbox({
    text  = "Monthly Budget",
    align = "center",
    font  = beautiful.font_med_m,
  }),
  {
    budget_entries,
    left   = dpi(30),
    right  = dpi(30),
    widget = wibox.container.margin,
  },
  spacing = dpi(10),
  forced_width = dpi(450),
  layout  = wibox.layout.fixed.vertical,
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

ledger:connect_signal("refresh", function(self)
  self:get_budget()
end)

ledger:connect_signal("ready::budget", function(_, bdata)
  budget_entries:reset()
  for i = 1, #bdata do
    local e = gen_entry(bdata[i])
    budget_entries:add(e)
  end
end)

return ui.dashbox(ui.place(budget), dpi(450), dpi(500))
