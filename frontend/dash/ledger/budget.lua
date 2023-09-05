
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

  local amount_color = (allotted - spent) < 0 and beautiful.red[300]
                          or beautiful.neutral[300]

  local amounts = ui.textbox({
    text   = ledger:format(spent) ..' / '.. ledger:format(allotted),
    align  = "right",
    valign = "end",
    color  = amount_color
  })

  local barval = (spent / allotted) * 100
  local bar = wibox.widget({
    color  = beautiful.random_accent_color(),
    background_color = beautiful.neutral[500],
    forced_height = dpi(3),
    value = barval,
    max_value = 100,
    shape  = ui.rrect(dpi(3)),
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
    forced_width = dpi(280),
    layout = wibox.layout.fixed.vertical,
  })
end

-- Assembly
local budget_entries = wibox.widget({
  spacing = dpi(25),
  forced_height = dpi(420),
  layout  = wibox.layout.flex.vertical,
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

return ui.dashbox(
  ui.place(budget_entries),
  dpi(390), -- width
  dpi(500)  -- height
)
