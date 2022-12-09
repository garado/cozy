
-- █▀▄▀█ █▀█ █▄░█ ▀█▀ █░█ █░░ █▄█ 
-- █░▀░█ █▄█ █░▀█ ░█░ █▀█ █▄▄ ░█░ 
--
-- █▄▄ █░█ █▀▄ █▀▀ █▀▀ ▀█▀
-- █▄█ █▄█ █▄▀ █▄█ ██▄ ░█░

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local wheader = require("helpers.ui").create_dash_widget_header
local ledger = require("core.system.ledger")

local bars

------------------

local function create_bar(category, spent, budgeted, color)
  -- Progress bar
  local bar = wibox.widget({
    color = color,
    background_color = beautiful.cash_budgetbar_bg,
    value = spent,
    max_value = budgeted,
    border_width = dpi(0),
    forced_width = dpi(320),
    forced_height = dpi(5),
    widget = wibox.widget.progressbar,
  })

  local text_color
  if spent < budgeted then
    text_color = beautiful.fg
  else
    text_color = beautiful.red
  end

  local category_label = wibox.widget({
    align = "left",
    valign = "center",
    ellipsize = "end",
    markup = colorize(category, text_color),
    font = beautiful.alt_font_name .. "15",
    widget = wibox.widget.textbox,
  })

  local spent_text    = string.format("%.2f", spent)
  local budgeted_text = string.format("%.2f", budgeted)
  local label_text    = spent_text .. " / " .. budgeted_text
  local spent_label = wibox.widget({
    align = "end",
    valign = "center",
    ellipsize = "end",
    font = beautiful.alt_font_name .. "11",
    markup = colorize(label_text, text_color),
    widget = wibox.widget.textbox,
  })

  -- Assemble budget entry
  return wibox.widget({
    {
      category_label,
      nil,
      spent_label,
      forced_height = dpi(30),
      layout = wibox.layout.align.horizontal,
    },
    bar,
    spacing = dpi(3),
    layout = wibox.layout.fixed.vertical,
  })
end

local function create_bars(budget)
  bars:reset()
  local i = 1
  for k, v in pairs(budget) do
    local color = beautiful.accents[i]
    local bar = create_bar(k, v[1], v[2], color)
    bars:add(bar)
    i = i + 1
  end
end

-----------------------------------------

bars = wibox.widget({
  spacing = dpi(15),
  layout = wibox.layout.flex.vertical,
})

local widget = wibox.widget({
  {
    wheader("Monthly Budget"),
    bars,
    spacing = dpi(15),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

ledger:connect_signal("update::budget", function(_)
  create_bars(ledger:get_budget())
end)

return box(widget, dpi(0), dpi(600), beautiful.dash_widget_bg)

