
--  █▀▄▀█ █▀█ █▄░█ ▀█▀ █░█ █░░ █▄█ 
--  █░▀░█ █▄█ █░▀█ ░█░ █▀█ █▄▄ ░█░ 
--
--  █▀ █▀█ █▀▀ █▄░█ █▀▄ █ █▄░█ █▀▀
--  ▄█ █▀▀ ██▄ █░▀█ █▄▀ █ █░▀█ █▄█

-- Integrated with ledger:
-- https://github.com/ledger/

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")
local naughty = require("naughty")
local animation = require("modules.animation")
local user_vars = require("user_variables")

local string = string
local tonumber = tonumber
local table = table
local ledger_file = user_vars.ledger.ledger_file

-- arc chart colors
local color_palette = {
  beautiful.nord7,
  beautiful.nord8,
  beautiful.nord9,
  beautiful.nord10,
  beautiful.nord11,
  beautiful.nord12,
  beautiful.nord13,
  beautiful.nord14,
  beautiful.nord15,
}

local function create_chart()
  local chart = wibox.widget({
    {
      {
        id = "text",
        font = beautiful.header_font_name .. "12",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      id = "arc",
      color = beautiful.nord12,
      thickness = 30,
      border_width = 0,
      widget = wibox.container.arcchart,
    },
    forced_height = dpi(120),
    forced_width = dpi(120),
    widget = wibox.container.place,
  })
  
  local function create_legend_entry(text, amount, color)
    local circle = wibox.widget({
      markup = helpers.ui.colorize_text("", color),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "start",
    })

    local label = wibox.widget({
      markup = helpers.ui.colorize_text(text, beautiful.xforeground),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "start",
    })

    local amount_ = wibox.widget({
      markup = helpers.ui.colorize_text("— $" .. amount, beautiful.nord3),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "start",
    })

    local legend_entry = wibox.widget({
      {
        circle,
        label,
        amount_,
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
        forced_width = dpi(300),
      },
      widget = wibox.container.place,
    })
    
    return legend_entry 
  end

  local legend = wibox.widget({
    spacing = dpi(3),
    layout = wibox.layout.fixed.vertical,
  })
 
  local function create_new_chart_section(entries, num_entries, total_spending)
    local arc_values = { }
    local colors = { }
    local arc_text = chart:get_children_by_id("text")[1]
    local arc_chart = chart:get_children_by_id("arc")[1]
    
    arc_chart.min_value = 0
    arc_chart.max_value = tonumber(total_spending)

    local cat = 1 -- category
    local amt = 2
    local bal = 3
    for i, v in ipairs(entries) do
      table.insert(arc_values, tonumber(v[amt]))
      table.insert(colors, color_palette[i])
      local amount = v[amt]
      amount = string.format("%.2f", amount) -- force 2 decimal places
      legend:add(create_legend_entry(v[cat], amount, color_palette[i]))
    end
 
    -- :)
    arc_chart.colors = colors
    arc_chart.values = arc_values
  end -- end breakdown chart creation

  local cmd = "ledger -f " .. ledger_file .. " -M csv register expenses"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- split on newlines
    local lines = { }
    for str in stdout:gmatch("[^\r\n]+") do
      table.insert(lines, str)
    end
      
    -- ledger outputs look like this:
    --    Expenses:Personal:Food  $29.50
    --    Expenses:Fees           $0.10   

    -- subcategories are separated by colons
    -- if (num subcategories) > 1 then
    --    category to show = 2nd to last subcategory
    -- else
    --    category to show = last subcategory
    local entries = { }
    local num_entries = 0
    for i,v in ipairs(lines) do
      local t =  { }
      local count = 0
      -- split string on colons
      for i in string.gmatch(v, "[^:]+") do
        table.insert(t, i)
        count = count + 1
      end

      local category, amount
      if count > 2 then -- more than 1 subcategory
        category = t[count - 1]
        amount = string.gsub(t[count], "[^0-9.]", "")
      else
        category = t[count]
        category = string.gsub(category, "\"(.*)", "")
        amount = string.gsub(t[count], "[^0-9.]", "")
      end

      -- Insert into table full of entries
      local category_already_exists = false
      for i, v in ipairs(entries) do
        if v[1] == category then
          v[2] = v[2] + tonumber(amount)
          category_already_exists = true
        end
      end

      if not category_already_exists then
        table.insert(entries, { category, tonumber(amount) })
        num_entries = num_entries + 1
      end
    end -- end loop iterating through lines in stdout

    -- now that we have all the entries, we can create the arc chart
    local total_spending = 0
    for i, v in ipairs(entries) do
      total_spending = total_spending + v[2]
    end
    create_new_chart_section(entries, num_entries, total_spending)
  end) -- end awful.spawn

  return { chart, legend }
end -- end create_chart

-- header_text  account name to display   
-- ledger_cmd   command that produces the necessary data
local function get_account_value(header_text, ledger_cmd)
  local header = wibox.widget({
    markup = helpers.ui.colorize_text(header_text, beautiful.nord3),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
  })

  local balance_ = wibox.widget({
    markup = helpers.ui.colorize_text("$--.--", beautiful.xforeground),
    widget = wibox.widget.textbox,
    font = beautiful.header_font_name .. "15",
    align = "center",
    valign = "center",
  })

  awful.spawn.easy_async_with_shell(ledger_cmd, function(stdout)
    balance = string.gsub(stdout, "[^0-9.]", "")
    balance = string.gsub(balance, "%s+", "")
    local markup = helpers.ui.colorize_text("$" .. balance, beautiful.xforeground)
    balance_:set_markup_silently(markup)
  end)

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

local function transactions()
  local header = wibox.widget({
    markup = helpers.ui.colorize_text("transactions", beautiful.nord3),
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  })

  local function create_transaction_entry(date, amount, title, isExpense)
    local textColor, prefix
    if isExpense then
      prefix = "-"
      textColor = beautiful.nord11
    else
      prefix = "+"
      textColor = beautiful.nord14
    end

    local date_ = wibox.widget({
      markup = helpers.ui.colorize_text(date, beautiful.nord3),
      widget = wibox.widget.textbox,
      align = "center",
      valign = "center",
    })
    
    local amount_ = wibox.widget({
      markup = helpers.ui.colorize_text(prefix .. "$" .. amount, textColor),
      widget = wibox.widget.textbox,
      align = "left",
      valign = "center",
      forced_width = dpi(100),
    })
    
    local title_ = wibox.widget({
      markup = helpers.ui.colorize_text(title, beautiful.xforeground),
      widget = wibox.widget.textbox,
      align = "left",
      valign = "center",
      forced_width = dpi(200),
    })
    
    local entry = wibox.widget({
      {
        amount_,
        title_,
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    })

    return entry 
  end

  local transactions_ = wibox.widget({
    create_transaction_entry("08/04", "23.75", "Betty Burgers", true),
    create_transaction_entry("08/04", "1167.66", "Deposit", false),
    create_transaction_entry("08/04", "15.00", "The Laundry Room", true),
    layout = wibox.layout.flex.vertical,
  })

  local widget = wibox.widget({
    {
      header,
      transactions_,
      spacing = dpi(5),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return widget
end

local widgets = create_chart()
local breakdown_chart = widgets[1]
local breakdown_legend = widgets[2]

local checking_cmd = "ledger -f " .. ledger_file .. " balance checking"
local savings_cmd = "ledger -f " .. ledger_file .. " balance savings"
local spent_cmd = "ledger -f " .. ledger_file .. " bal -M \\^Expenses | tail -n 1"

local top = wibox.widget({
  {
    {
      get_account_value("Checking", checking_cmd),
      get_account_value("Savings", savings_cmd),
      spacing = dpi(20),
      layout = wibox.layout.fixed.horizontal,
    },
    spacing = dpi(40),
    get_account_value("Spent", spent_cmd),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

local bottom = wibox.widget({
  {
    breakdown_chart,
    breakdown_legend,
    spacing = dpi(30),
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.place,
})

local header = wibox.widget({
  {
    markup = helpers.ui.colorize_text("Monthly Spending", beautiful.dash_header_color),
    font = beautiful.header_font .. "20",
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  },
  margins = dpi(5),
  widget = wibox.container.margin,
})

local widget = wibox.widget({
  header,
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
})

return helpers.ui.create_boxed_widget(widget, dpi(300), dpi(300), beautiful.dash_widget_bg)
