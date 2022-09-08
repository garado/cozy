
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
local naughty = require("naughty")
local user_vars = require("user_variables")

local string = string
local tonumber = tonumber
local math = math
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
    spacing = dpi(10),
    layout = wibox.layout.flex.vertical,
  })

  -- creates a single budget bar
  local function create_budget_entry(entry, i)
    local spent = string.gsub(entry[1], "[^0-9.]", "")
    spent = tonumber(spent)
    local budgeted = string.gsub(entry[2], "[^0-9.]", "")
    budgeted = tonumber(budgeted)
    local percent = string.gsub(entry[4], "[^0-9]", "")
    percent = tonumber(percent)
    local category = entry[5]

    -- assemble the wibox
    local random_accent = beautiful.accents[i]
    local bar = wibox.widget({
      capacity = 2,
      min_value = 0,
      max_value = tonumber(budgeted),
      background_color = beautiful.dash_widget_bg,
      nan_color = beautiful.red,
      group_colors = { 
        random_accent, 
        beautiful.surface1,
      },
      stack = true,
      scale = true,
      clamp_bars = true,
      step_spacing = dpi(0),
      -- this gets rotated, so the height is
      -- actually the width and vice versa
      step_width = dpi(5),
      forced_width = dpi(15),
      forced_height = dpi(300),
      widget = wibox.widget.graph,
    })

    local text_color
    if spent < budgeted then
      bar:add_value(spent, 1)
      bar:add_value(budgeted - spent, 2)
      text_color = beautiful.fg
    else
      bar:add_value(budgeted, 1)
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
      {
        bar,
        direction = "west",
        widget = wibox.container.rotate,
      },
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

return helpers.ui.create_boxed_widget(create_graph(), dpi(0), dpi(450), beautiful.dash_widget_bg)
