
-- █▄▄ █░█ █▀▄ █▀▀ █▀▀ ▀█▀
-- █▄█ █▄█ █▄▀ █▄█ ██▄ ░█░

-- Integrated with ledger:
-- https://github.com/ledger/

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")
local helpers = require("helpers")
--local widgets = require("ui.widgets")
local naughty = require("naughty")
local animation = require("modules.animation")
local user_vars = require("user_variables")
--local math = math

local function breakdown()
  local chart = wibox.widget({
    {
      {
        markup = helpers.ui.colorize_text("$1100", beautiful.nord4),
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      id = "arc",
      min_value = 0,
      max_value = 1100,
      values = { 
        0, -- rent
        200, 
        300,
      },
      value = 100,
      color = beautiful.nord12,
      colors = { 
        beautiful.nord12, -- rent
        beautiful.nord13, 
      },
      thickness = 10,
      widget = wibox.container.arcchart,
    },
    forced_height = dpi(100),
    widget = wibox.container.place,
  })

  ----------------
  -- Animations --
  ----------------
  local arc = chart:get_children_by_id("arc")[1]
  local arc1val = 900
  local arc2val = 200
  local arc_animation = animation:new({
    duration = 1,
    easing = animation.easing.inOutExpo,
    reset_on_stop = true,
    update = function(self, pos)
      if dpi(pos) < 900 then
        arc.values = { dpi(pos), 0 }
      else
        arc.values = { arc1val, dpi(pos) - arc1val }
      end
    end,
  })

  -- when dashboard opens, start animation
  -- need a better signal
  awesome.connect_signal("dash::open", function()
    arc_animation:set(1100)
  end)
  
  awesome.connect_signal("dash::close", function()
    arc_animation:set(0)
  end)

  ------------
  -- Legend --
  ------------
  local function create_legend_entry(text, amount, color)
    local circle = wibox.widget({
      markup = helpers.ui.colorize_text("", color),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "center",
    })

    local label = wibox.widget({
      markup = helpers.ui.colorize_text(text, beautiful.xforeground),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "center",
    })

    local amount_ = wibox.widget({
      markup = helpers.ui.colorize_text("— $" .. amount, beautiful.nord3),
      widget = wibox.widget.textbox,
      valign = "center",
      align = "center",
    })

    local legend_entry = wibox.widget({
      {
        circle,
        label,
        amount_,
        spacing = dpi(10),
        layout = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    })
    
    return legend_entry 
  end

  local legend = wibox.widget({
    create_legend_entry("Rent", "900", beautiful.nord12),
    create_legend_entry("Other", "200", beautiful.nord13),
    layout = wibox.layout.fixed.vertical,
  })

  local header = wibox.widget({
    markup = helpers.ui.colorize_text("Budget", beautiful.nord10),
    widget = wibox.widget.textbox,
    font = beautiful.header_font_name .. "Medium 20",
    align = "center",
    valign = "center",
  })

  local breakdown_widget = wibox.widget({
    {
      header,
      chart,
      legend,
      spacing = dpi(20),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return breakdown_widget
end

local function balance()
  local header = wibox.widget({
    markup = helpers.ui.colorize_text("total balance", beautiful.nord3),
    widget = wibox.widget.textbox,
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
      spacing = dpi(5),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })

  return balance
end

local function monthly_spending()
  local header = wibox.widget({
    markup = helpers.ui.colorize_text("spent this month", beautiful.nord3),
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  })

  local amount = wibox.widget({
    markup = helpers.ui.colorize_text("$168.90", beautiful.xforeground),
    widget = wibox.widget.textbox,
    font = beautiful.header_font_name .. "20",
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
    spacing = dpi(5),
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

local right = wibox.widget({
  {
    balance(),
    monthly_spending(),
    --transactions(),
    spacing = dpi(20),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})

local widget = wibox.widget({
  breakdown(),
  right,
  layout = wibox.layout.flex.horizontal,
})

return helpers.ui.create_boxed_widget(widget, dpi(300), dpi(310), beautiful.dash_widget_bg)
