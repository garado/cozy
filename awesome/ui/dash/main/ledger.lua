
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

-- Arc chart showing monthly spending.
-- Also shows account balances and total spent this month.

local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local animation = require("modules.animation")
local colorize = require("helpers.ui").colorize_text
local box = require("helpers.ui").create_boxed_widget
local ledger = require("core.system.ledger")
local dash = require("core.cozy.dash")

-- Module-level variables
local chart, legend
local color_palette = beautiful.cash_arccolors

----------------------------

-- █░░ █▀▀ █▀▀ █▀▀ █▄░█ █▀▄ 
-- █▄▄ ██▄ █▄█ ██▄ █░▀█ █▄▀ 

--- Creates entry for the legend for the arc chart.
-- @param text The name of the spending category
-- @param amount How much was spent 
-- @param color ... the color
-- @return A textbox widget to be added to the legend wibox
local function create_legend_entry(text, amount, color)
  local circle = colorize(" ", color)
  local label = colorize(text, beautiful.fg)
  local amt = colorize(" — $" .. amount, beautiful.cash_alttext_fg)

  local legend_entry = wibox.widget({
    markup = circle .. label .. amt,
    valign = "center",
    align = "start",
    widget = wibox.widget.textbox,
  })

  return legend_entry
end -- end create_legend_entry()

local function create_legend(entries)
  local cnt = 1
  for k, v in pairs(entries) do
    local legend_entry = create_legend_entry(k, v, color_palette[cnt])
    legend.children[1]:add(legend_entry)
    cnt = cnt + 1
  end
end


-- ▄▀█ █▀█ █▀▀    █▀▀ █░█ ▄▀█ █▀█ ▀█▀ 
-- █▀█ █▀▄ █▄▄    █▄▄ █▀█ █▀█ █▀▄ ░█░ 

--- Create chart section
-- @param entries A table (kv) containing categories and amt spent per category
-- @param total_spending Total spent this month
local function create_chart_sections(entries, total_spending)
  -- Table of dummy values for animation
  local tmp_arc_values = { }

  local arc_values = { }
  local colors = { }
  local arc_chart = chart:get_children_by_id("arc")[1]

  arc_chart.min_value = 0
  arc_chart.max_value = tonumber(total_spending)

  local cnt = 1
  for cat, amt in pairs(entries) do
    table.insert(tmp_arc_values, 0)
    table.insert(arc_values, (tonumber(amt)))
    table.insert(colors, color_palette[cnt])
    cnt = cnt + 1
  end

  -- Create arc chart animation
  arc_chart.values = tmp_arc_values
  local section_index = 1
  local max_index = #arc_chart.values
  local relative_max = arc_values[1] or 0
  local sub = 0
  local arc_chart_animation = animation:new({
    duration = 1,
    easing = animation.easing.inOutExpo,
    reset_on_stop = true,
    update = function(self, pos)
      if pos < relative_max then
        arc_chart.values[section_index] = pos - sub
        arc_chart:emit_signal("widget::redraw_needed")
      else
        arc_chart.values[section_index] = arc_values[section_index]
        if section_index < max_index then
          section_index = section_index + 1
          sub = relative_max
          relative_max = relative_max + arc_values[section_index]
        end
      end

      -- the animation doesn't end properly (probably something to
      -- do with it being a decimal number)
      -- so this is a hacky fix to make the animation end
      if pos >= math.floor(arc_chart.max_value)  then
        self:stop()
        arc_chart.values[section_index] = arc_values[section_index]
      end
    end,
  })

  dash:connect_signal("updatestate::open", function()
    arc_chart_animation:set(arc_chart.max_value)
  end)

  arc_chart.colors = colors
end -- end create_chart_sections

--- Create wiboxes showing account balances/total spent
-- @param header_text  account name to display   
-- @param ledger_cmd   command that produces the necessary data
local function create_account_displays(header_text)
  local header = wibox.widget({
    markup = colorize(header_text, beautiful.cash_acct_name),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
  })

  local balance = wibox.widget({
    id = "balance",
    markup = colorize("$0.00", beautiful.fg),
    widget = wibox.widget.textbox,
    font = beautiful.alt_font_name .. "15",
    align = "center",
    valign = "center",
  })

  local widget = wibox.widget({
    {
      header,
      balance,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return widget
end

-----------------------------

-- █░█ █ 
-- █▄█ █ 

local checking_bal = create_account_displays("Checking")
local savings_bal  = create_account_displays("Savings")
local total_spent  = create_account_displays("Spent")

chart = wibox.widget({
  {
    {
      id = "text",
      font = beautiful.alt_font_name .. "12",
      align = "center",
      valign = "center",
      widget = wibox.widget.textbox,
    },
    id = "arc",
    thickness = 30,
    border_width = 0,
    widget = wibox.container.arcchart,
  },
  forced_height = dpi(120),
  forced_width = dpi(120),
  widget = wibox.container.place,
})

legend = wibox.widget({
  {
    spacing = dpi(3),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

-- Row of account balances
local top = wibox.widget({
  {
    checking_bal,
    savings_bal,
    total_spent,
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

-- Arc chart or placeholder text
local bottom_yes_spent = wibox.widget({
    {
      chart,
      legend,
      spacing = dpi(30),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })

local bottom_no_spent = wibox.widget({
  {
    text    = "Nothing spent this month.",
    widget  = wibox.widget.textbox,
  },
  widget = wibox.container.place,
})

local bottom = wibox.widget({
  top,
  bottom_no_spent,
  spacing = dpi(20),
  layout = wibox.layout.fixed.vertical,
})

local widget = wibox.widget({
  helpers.ui.create_dash_widget_header("Ledger"),
  {
    bottom,
    widget = wibox.container.place,
  },
  layout = wibox.layout.align.vertical,
  widget = wibox.container.place,
})

-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- Update arc chart and total spending balance
-- BUG: setting bottom_yes_spent not working
ledger:connect_signal("update::month", function()
  local entries = ledger:get_monthly_overview()
  local total = ledger:get_total_spent_this_month()

  if tonumber(total) == 0 then
    bottom.set(2, bottom_no_spent)
  else
    create_chart_sections(entries, total)
    create_legend(entries)

    local markup = colorize("$" .. total)
    local spent = total_spent.children[1].children[2]
    spent:set_markup_silently(markup)
    bottom.set(2, bottom_yes_spent)
  end
end)

-- Update checking and savings balance
ledger:connect_signal("update::balances", function()
  local checking_value  = ledger:get_account_balance("checking")
  local savings_value   = ledger:get_account_balance("savings")

  local checking = checking_bal.children[1].children[2]
  checking:set_markup_silently(colorize(checking_value, beautiful.fg))

  local savings = savings_bal.children[1].children[2]
  savings:set_markup_silently(colorize(savings_value, beautiful.fg))
end)

return box(widget, dpi(0), dpi(310), beautiful.dash_widget_bg)
