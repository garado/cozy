
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
local ledger_file = user_vars.dash.ledger_file

-- Each category of spending gets a color in the arc chart
-- This table defines those colors
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
      thickness = 15,
      border_width = 0,
      widget = wibox.container.arcchart,
    },
    forced_height = dpi(120),
    widget = wibox.container.place,
  })
  
  ------------
  -- Legend --
  ------------
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
  
  --------------
  -- Get data --
  --------------
  local function create_new_chart_section(entries, num_entries, total_spending)
    local arc_values = { }
    local colors = { }
    local arc_text = chart:get_children_by_id("text")[1]
    local arc_chart = chart:get_children_by_id("arc")[1]
    
    -- Set values
    arc_chart.min_value = 0
    arc_chart.max_value = tonumber(total_spending)
    arc_text:set_markup_silently(helpers.ui.colorize_text("$" .. total_spending, beautiful.xforeground))

    -- category: 1
    -- amount: 2
    -- balance: 3
    for i, v in ipairs(entries) do
      table.insert(arc_values, tonumber(v[2]))
      table.insert(colors, color_palette[i])
      legend:add(create_legend_entry(v[1], v[2], color_palette[i]))
    end
  
    --arc_chart.values = arc_values
    arc_chart.colors = colors
    arc_chart.values = arc_values
  end -- end breakdown chart creation

  local cmd = "ledger -f " .. ledger_file .. " -M csv register expenses"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Split on newlines
    local lines = { }
    for str in stdout:gmatch("[^\r\n]+") do
      table.insert(lines, str)
    end
      
    -- Outputs look like this:
    --    Expenses:Personal:Food  $29.50
    --    Expenses:Fees           $0.10   

    -- subcategories are separated by colons
    -- if (num subcategories) > 1 then
    --    Category to show = 2nd to last subcategory
    -- else
    --    Category to display = last subcategory
    local entries = { }
    local num_entries = 0
    for i,v in ipairs(lines) do
      -- Detect num subcategories based on # of colons
      local _, colon_count = string.gsub(v, "%:", "")
      local isolated
      local category, amount
      if colon_count == 1 then
        -- Isolate category and category total by splitting 
        -- on last colon
        local s, e = v:find(":[^:]*$")
        local substring = v:sub(s+1)

        category = string.gsub(substring, "\"(.*)", "")
        amount = string.gsub(substring, "[^0-9.]", "")
      else
        local t =  { }
        local count = 0
        for i in string.gmatch(v, "[^:]+") do
          table.insert(t, i)
          count = count + 1
        end
        category = t[count - 1]
        local substring = t[count]
        amount = string.gsub(substring, "[^0-9.]", "")
      end

      -- Insert into table full of entries
      local categoryWasFound = false
      for i, v in ipairs(entries) do
        if v[1] == category then
          v[2] = v[2] + tonumber(amount)
          categoryWasFound = true
        end
      end

      if not categoryWasFound then
        table.insert(entries, { category, tonumber(amount) })
        num_entries = num_entries + 1
      end
    end

    -- Now that we have all the entries, we can create the arc chart
    local total_spending = 0
    for i, v in ipairs(entries) do
      total_spending = total_spending + v[2]
    end
    create_new_chart_section(entries, num_entries, total_spending)
  end)

  return { chart, legend }
end

-- Returns current checking balance.
local function balance()
  local header = wibox.widget({
    markup = helpers.ui.colorize_text("balance", beautiful.nord3),
    widget = wibox.widget.textbox,
    font = beautiful.font .. "12",
    align = "center",
    valign = "center",
  })

  local balance_ = wibox.widget({
    markup = helpers.ui.colorize_text("$341", beautiful.xforeground),
    widget = wibox.widget.textbox,
    font = beautiful.header_font_name .. "20",
    align = "center",
    valign = "center",
  })

  local ledger_file = user_vars.dash.ledger_file
  local cmd = "ledger -f " .. ledger_file .. " balance checking"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    balance = string.gsub(stdout, "Assets:Checking", "")
    balance = string.gsub(balance, "%s+", "")
    local markup = helpers.ui.colorize_text(balance, beautiful.xforeground)
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

-- Returns amount spent this month.
local function monthly_spending()
  local header = wibox.widget({
    markup = helpers.ui.colorize_text("spent this month", beautiful.nord3),
    widget = wibox.widget.textbox,
    font = beautiful.font .. "10",
    align = "center",
    valign = "center",
  })

  local amount = wibox.widget({
    markup = helpers.ui.colorize_text("$168.90", beautiful.xforeground),
    widget = wibox.widget.textbox,
    font = beautiful.header_font_name .. "18",
    align = "center",
    valign = "center",
  })
  
  local ledger_file = user_vars.dash.ledger_file
  local cmd = "ledger -f " .. ledger_file .. " -M reg expenses | tail -1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local total = string.match(stdout, "$(.*)")
    total = string.match(total, "$(.*)")
    total = string.gsub(total, "%s+", "")
    local markup = helpers.ui.colorize_text("$" .. total, beautiful.xforeground)
    amount:set_markup_silently(markup)
  end)

  local widget = wibox.widget({
    header,
    amount,
    layout = wibox.layout.fixed.vertical,
  })

  return widget
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

local left = wibox.widget({
  {
    breakdown_chart,
    balance(),
    --{
    --  balance(),
    --  layout = wibox.layout.fixed.vertical,
    --  spacing = dpi(10),
    --},
    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical,
  },
  forced_width = dpi(150),
  widget = wibox.container.place,
})

local right = wibox.widget({
  breakdown_legend,
  balance(),
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
    left,
    right,
    spacing = dpi(10),
    layout = wibox.layout.align.horizontal,
  },
  layout = wibox.layout.align.vertical,
})

return helpers.ui.create_boxed_widget(widget, dpi(300), dpi(310), beautiful.dash_widget_bg)
