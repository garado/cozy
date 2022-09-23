
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
local helpers = require("helpers")
local user_vars = require("user_variables")
local widgets = require("ui.widgets")

local string = string
local tonumber = tonumber
local table = table
local ledger_file = user_vars.ledger.ledger_file
local budget_file = user_vars.ledger.budget_file

-- fields:
--    amount spent
--    amount budgeted
--    name
local budget_entries = { }


-- parses stdout of ledger command and puts data into
-- budget_entries table
local function parse(stdout)
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
end

-- Creates total budget summary
local summary = wibox.widget({
  {
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place,
})
local function create_summary()
  -- Calculate sum
  local total_spent   = 0
  local total_budget  = 0
  for i = 1, #budget_entries do
    local spent = budget_entries[i][1]
    local budget = budget_entries[i][2]
    spent = string.gsub(spent, "[^0-9.]", "")
    budget = string.gsub(budget, "[^0-9.]", "")
    total_spent   = total_spent + (spent or 0)
    total_budget  = total_budget + (budget or 0)
  end

  -- Create UI elements

  -- Header
  local header = widgets.text ({
    font = beautiful.font,
    color = beautiful.fg,
    bold = false,
    size = 10,
    text = "TOTAL SPENDING",
    halign = "center",
    valign = "center",
  })

  local text = total_spent .. " / " .. total_budget
  local color = (total_spent >= total_budget and beautiful.red) or beautiful.fg
  local fuck = widgets.text ({
    font = beautiful.alt_font,
    color = color,
    bold = false,
    size = 20,
    text = text,
    halign = "center",
    valign = "center",
  })

  summary.children[1]:add(header)
  summary.children[1]:add(fuck)
end

-- Creates individual budget category bar
local function create_bars()
  -- bars will be appended here 
  local bars = wibox.widget({
    spacing = dpi(15),
    layout = wibox.layout.flex.vertical,
  })

  -- creates a single budget bar
  local function create_budget_entry(entry, i)
    local spent_str = string.gsub(entry[1], "[^0-9.]", "")
    local spent = tonumber(spent_str)
    local budgeted_str = string.gsub(entry[2], "[^0-9.]", "")
    local budgeted = tonumber(budgeted_str)
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

    local spent_text    = string.format("%.2f", spent)
    local budgeted_text = string.format("%.2f", budgeted)
    local label_text    = spent_text .. " / " .. budgeted_text
    local spent_label = wibox.widget({
      align = "end",
      valign = "center",
      ellipsize = "end",
      font = beautiful.alt_font_name .. "11",
      markup = helpers.ui.colorize_text(label_text, text_color),
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
    parse(stdout)
    create_summary()
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
      helpers.ui.vertical_pad(dpi(5)),
      summary,
      spacing = dpi(15),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.place,
  })
end

return helpers.ui.create_boxed_widget(create_bars(), dpi(0), dpi(600), beautiful.dash_widget_bg)
