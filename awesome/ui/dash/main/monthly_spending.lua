
--  █▀▄▀█ █▀█ █▄░█ ▀█▀ █░█ █░░ █▄█ 
--  █░▀░█ █▄█ █░▀█ ░█░ █▀█ █▄▄ ░█░ 
--
--  █▀ █▀█ █▀▀ █▄░█ █▀▄ █ █▄░█ █▀▀
--  ▄█ █▀▀ ██▄ █░▀█ █▄▀ █ █░▀█ █▄█

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

----------------------------

-- Module-level variables
local chart, legend
local no_spending_this_month = false
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
    print(cat .. amt)
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

  awesome.connect_signal("dash::opened", function()
    arc_chart_animation:set(arc_chart.max_value)
  end)

  arc_chart.colors = colors
end -- end create_chart_sections

-- @param header_text  account name to display   
-- @param ledger_cmd   command that produces the necessary data
local function update_account_values(header_text)
  local header = wibox.widget({
    markup = colorize(header_text, beautiful.cash_acct_name),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
  })

  local balance_ = wibox.widget({
    id = "balance",
    markup = colorize("$0.00", beautiful.fg),
    widget = wibox.widget.textbox,
    font = beautiful.alt_font_name .. "15",
    align = "center",
    valign = "center",
  })

  local balance = wibox.widget({
    {
      header,
      balance_,
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return balance
end

-----------------------------

local checking_bal = update_account_values("Checking")
local savings_bal  = update_account_values("Savings")
local total_spent  = update_account_values("Spent")

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

local top = wibox.widget({
  {
    {
      checking_bal,
      savings_bal,
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(40),
    -- get_account_value("Spent", spent_cmd),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

local bottom = wibox.widget({
    {
      chart,
      legend,
      spacing = dpi(30),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
  })

--   print("no spend")
--   bottom = wibox.widget({
--     text = "no spending",
--     widget = wibox.widget.text,
--   })
-- end

local widget = wibox.widget({
  helpers.ui.create_dash_widget_header("Monthly Spending"),
  {
    {
      top,
      bottom,
      spacing = dpi(20),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  },
  layout = wibox.layout.align.vertical,
  widget = wibox.container.place,
})

ledger:connect_signal("update::month", function(_)
  local entries = ledger:get_monthly_overview()
  local total = ledger:get_total_spent_this_month()
  create_chart_sections(entries, total)
  create_legend(entries)
end)

return box(widget, dpi(0), dpi(310), beautiful.dash_widget_bg)
