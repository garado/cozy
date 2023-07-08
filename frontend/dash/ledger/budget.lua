
-- █▄▄ █░█ █▀▄ █▀▀ █▀▀ ▀█▀ 
-- █▄█ █▄█ █▄▀ █▄█ ██▄ ░█░ 

local ui  = require("utils.ui")
local dpi = ui.dpi
local beautiful  = require("beautiful")
local wibox = require("wibox")
local ledger = require("backend.system.ledger")

-- @function gen_entry
-- @brief Generates a progress bar showing percent fulfillment of a budget category.
-- @param category Budget category
local function gen_entry(category)
  local label = ui.textbox({
    text = category,
    font = beautiful.font_reg_m,
    valign = "end",
  })

  local amounts = ui.textbox({
    text   = "Remaining: 0.00",
    align  = "right",
    valign = "end",
    color  = beautiful.neutral[300],
  })

  local barval = math.random() * 100
  local bar = wibox.widget({
    color  = beautiful.random_accent_color(),
    background_color = beautiful.neutral[700],
    max_value = 100,
    value = barval,
    forced_height = dpi(8),
    shape = ui.rrect(),
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

local budget = wibox.widget({
  ui.textbox({
    text  = "Monthly Budget",
    align = "center",
    font  = beautiful.font_med_m,
  }),
  {
    {
      gen_entry("Bills"),
      gen_entry("Groceries"),
      gen_entry("Personal"),
      gen_entry("Transportation"),
      gen_entry("Household"),
      gen_entry("Hobby"),
      gen_entry("Other"),
      spacing = dpi(20),
      layout = wibox.layout.flex.vertical,
    },
    left   = dpi(30),
    right  = dpi(30),
    widget = wibox.container.margin,
  },
  spacing = dpi(10),
  layout  = wibox.layout.fixed.vertical,
})


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

ledger:get_budget()

ledger:connect_signal("ready::budget", function(_, bdata)
  require("utils.string").print_arr(bdata)
end)

return ui.dashbox(budget, dpi(450), dpi(800))
