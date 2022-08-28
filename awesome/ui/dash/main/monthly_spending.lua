
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
local color_palette = beautiful.arcchart_colors

local function create_chart()
  local chart = wibox.widget({
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
  
  local function create_legend_entry(text, amount, color)
    local circle = wibox.widget({
      markup = helpers.ui.colorize_text("", color),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "start",
    })

    local label = wibox.widget({
      markup = helpers.ui.colorize_text(text, beautiful.fg),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "start",
    })

    local amount_ = wibox.widget({
      markup = helpers.ui.colorize_text("— $" .. amount, beautiful.legend_amount),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "start",
    })

    local legend_entry = wibox.widget({
        circle,
        label,
        amount_,
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
        forced_width = dpi(300),
    })
    
    return legend_entry 
  end -- end create_legend_entry()

  local legend = wibox.widget({
    {
      spacing = dpi(3),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
 
  local function create_chart_sections(entries, num_entries, total_spending)
    -- table of dummy values for animation
    local tmp_arc_values = { }
    
    local arc_values = { }
    local colors = { }
    local arc_text = chart:get_children_by_id("text")[1]
    local arc_chart = chart:get_children_by_id("arc")[1]
    
    arc_chart.min_value = 0
    arc_chart.max_value = tonumber(total_spending)

    for i = 1, #entries do
      local cat = entries[i][1] -- category
      local amt = entries[i][2]
      local bal = entries[i][3]
      table.insert(tmp_arc_values, 0)
      table.insert(arc_values, (tonumber(amt)))
      table.insert(colors, color_palette[i])
      local amt_text = string.format("%.2f", amt) -- force 2 decimal places
      legend.children[1]:add(create_legend_entry(cat, amt_text, color_palette[i]))
    end

    -- arc chart animation
    arc_chart.values = tmp_arc_values
    local section_index = 1
    local max_index = #arc_chart.values
    local relative_max = arc_values[1]
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

    awesome.connect_signal("dash::open", function()
      arc_chart_animation:set(arc_chart.max_value)
    end)

    arc_chart.colors = colors
  end -- end create_chart_sections

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
    for i = 1, #lines do
      local t =  { }
      local count = 0
      -- split string on colons
      for i in string.gmatch(lines[i], "[^:]+") do
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
      for i = 1, #entries do
        if entries[i][1] == category then
          entries[i][2] = entries[i][2] + tonumber(amount)
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
    create_chart_sections(entries, num_entries, total_spending)
  end) -- end awful.spawn

  return { chart, legend }
end -- end create_chart

-- header_text  account name to display   
-- ledger_cmd   command that produces the necessary data
local function get_account_value(header_text, ledger_cmd)
  local header = wibox.widget({
    markup = helpers.ui.colorize_text(header_text, beautiful.account_title),
    widget = wibox.widget.textbox,
    font = beautiful.font_name .. "11",
    align = "center",
    valign = "center",
  })

  local balance_ = wibox.widget({
    markup = helpers.ui.colorize_text("$--.--", beautiful.fg),
    widget = wibox.widget.textbox,
    font = beautiful.alt_font_name .. "15",
    align = "center",
    valign = "center",
  })

  awful.spawn.easy_async_with_shell(ledger_cmd, function(stdout)
    balance = string.gsub(stdout, "[^0-9.]", "")
    balance = string.gsub(balance, "%s+", "")
    local markup = helpers.ui.colorize_text("$" .. balance, beautiful.fg)
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

return helpers.ui.create_boxed_widget(widget, dpi(300), dpi(300), beautiful.dash_widget_bg)
