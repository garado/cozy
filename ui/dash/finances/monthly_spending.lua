
-- █▄▄ █▀█ █▀▀ ▄▀█ █▄▀ █▀▄ █▀█ █░█░█ █▄░█
-- █▄█ █▀▄ ██▄ █▀█ █░█ █▄▀ █▄█ ▀▄▀▄▀ █░▀█

-- Arc chart for monthly spending breakdown

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local keygrabber = require("awful.keygrabber")
local helpers = require("helpers")
local user_vars = require("user_variables")
local animation = require("modules.animation")
local naughty = require("naughty")

local string = string
local tonumber = tonumber
local table = table
local ledger_file = user_vars.dash.ledger_file

-- Each category of spending gets a color in the arc chart
-- This table defines those colors
local color_palette = {
  beautiful.nord3,
  beautiful.nord6,
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
        font = beautiful.font_name .. "15",
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
    forced_height = dpi(200),
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
  local function create_new_chart_section(entries, num_entries)
    local total_spending = entries[num_entries][3]
    local arc_values = { }
    local colors = { }
    local arc_text = chart:get_children_by_id("text")[1]
    local arc_chart = chart:get_children_by_id("arc")[1]
    
    -- Set values
    arc_chart.min_value = 0
    arc_chart.max_value = tonumber(total_spending)
    arc_text:set_markup_silently(helpers.ui.colorize_text(total_spending, beautiful.xforeground))

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
  end -- end create chart

  local cmd = "ledger -f " .. ledger_file .. " -M -s --period-sort \"(amount)\" reg expenses"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Split on newlines
    local lines = { }
    for str in stdout:gmatch("[^\r\n]+") do
      table.insert(lines, str)
    end

    -- Outputs look like this:
    --    Expenses:Personal:Food  $29.50
    --    Expenses:Fees           $0.10   
    -- Category to show is after the 2nd to last colon,
    -- or the last colon if there's only one
    local entries = { }
    local num_entries = 0
    for i,v in ipairs(lines) do
      -- Count occurences
      local _, count = string.gsub(v, "%:", "")
      if count == 1 then
      else
        -- Isolate category and category total by splitting 
        -- on last colon
        local s, e = v:find(":[^:]*$")
        local isolated = v:sub(s+1)
      end


      -- Parse category and total by delimiting on whitespace
      local fields = { }
      for field in string.gmatch(isolated, "([^%s]+)") do
        table.insert(fields, field)
      end
     
      -- Insert into table full of entries
      local category = fields[1]
      local amount = string.gsub(fields[2], "[^0-9.]", "")
      local balance = fields[3]
      table.insert(entries, { category, amount, balance })
      num_entries = num_entries + 1
    end

    -- Now that we have all the entries, we can create the arc chart
    create_new_chart_section(entries, num_entries)
  end)



  local header = wibox.widget({
    markup = helpers.ui.colorize_text("Monthly spending", beautiful.nord3),
    widget = wibox.widget.textbox,
    font = beautiful.header_font_name .. "Light 20",
    align = "center",
    valign = "center",
  })

  local breakdown_widget = wibox.widget({
    header,
    chart,
    legend,
    spacing = dpi(30),
    layout = wibox.layout.fixed.vertical,
  })

  return breakdown_widget
end

return create_chart()
