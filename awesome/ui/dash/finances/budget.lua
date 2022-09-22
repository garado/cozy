
-- █▀▄▀█ █▀█ █▄░█ ▀█▀ █░█ █░░ █▄█ 
-- █░▀░█ █▄█ █░▀█ ░█░ █▀█ █▄▄ ░█░ 
--
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
local user_vars = require("user_variables")

local string = string
local tonumber = tonumber
local table = table
local ledger_file = user_vars.ledger.ledger_file
local budget_file = user_vars.ledger.budget_file

local function create_graph()

  -- called on output of ledger command
  local function parse(stdout)
    local budget_entries = { }

    -- split into lines
    local lines = { }
    for line in string.gmatch(stdout, "[^\r\n]+") do
      table.insert(lines, line)
    end

    -- split lines into fields
    -- the fields are: (in order)
    --   - amount spent on category
    --   - amount budgeted for category
    --   - how spending differed from budget
    --   - percentage of budget spent
    --   - category name
    for i = 1, #lines do
      local fields = { }
      for field in string.gmatch(lines[i], "[^%s]+") do
        table.insert(fields, field)
      end
      if #fields == 5 then
        table.insert(budget_entries, fields)
      end
    end

    table.remove(budget_entries, 1)
    table.remove(budget_entries, 1)
    return budget_entries
  end

  -- bars will be appended here 
  local bars = wibox.widget({
    spacing = dpi(15),
    layout = wibox.layout.flex.vertical,
  })

  -- creates a single budget bar
  local function create_budget_entry(entry, i)
    local _spent = string.gsub(entry[1], "[^0-9.]", "")
    local spent = tonumber(_spent)
    local _budgeted = string.gsub(entry[2], "[^0-9.]", "")
    local budgeted = tonumber(_budgeted)
    local _percent = string.gsub(entry[4], "[^0-9]", "")
    local percent = tonumber(_percent)
    local category = entry[5]

    local random_accent = beautiful.accents[i]
    local bar = wibox.widget({
      color = random_accent,
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
      markup = helpers.ui.colorize_text(category, text_color),
      font = beautiful.alt_font_name .. "15",
      widget = wibox.widget.textbox,
    })

    spent = string.format("%.2f", spent)
    budgeted = string.format("%.2f", budgeted)
    local spent_text = spent .. " / " .. budgeted
    local spent_label = wibox.widget({
      align = "end",
      valign = "center",
      ellipsize = "end",
      font = beautiful.alt_font_name .. "11",
      markup = helpers.ui.colorize_text(spent_text, text_color),
      widget = wibox.widget.textbox,
    })

    -- assemble budget entry
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

  -- fetch data from ledger
  local date = " --current --begin " .. os.date("%Y/%m/01")
  local files = " -f " .. ledger_file .. " -f " .. budget_file
  local cmd = "ledger " .. files .. date .. " budget"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local budget_entries = parse(stdout)
    for i = 1, #budget_entries do
      local bar = create_budget_entry(budget_entries[i], i)
      bars:add(bar)
    end
  end)

  -- assemble final widget
  return wibox.widget({
    {
      helpers.ui.create_dash_widget_header("Monthly Budget"),
      {
        bars,
        widget = wibox.container.place,
      },
      spacing = dpi(15),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
end

return helpers.ui.create_boxed_widget(create_graph(), dpi(0), dpi(600), beautiful.dash_widget_bg)
