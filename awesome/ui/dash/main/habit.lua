
-- █░█ ▄▀█ █▄▄ █ ▀█▀ █▀
-- █▀█ █▀█ █▄█ █ ░█░ ▄█

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local config = require("config")
local dpi = xresources.apply_dpi
local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local pixela = require("core.system.pixela")

local Area = require("modules.keynav.area")
local Habit = require("modules.keynav.navitem").Habit
local Dashwidget = require("modules.keynav.navitem").Dashwidget

local nav_dash_habits = Area:new({
  name = "nav_dash_habits",
  circular = true,
  is_grid_container = true,
})

local habit_list = config.habit
local habit_widget

---------------------------------

local function create_habit_ui_entry(name, graph_id, frequency)
  local nav_habit = Area:new({
    name = name,
    is_row = true,
    circular = true,
    row_wrap_vertical = true,
  })

  local habit_name = wibox.widget({
    markup = colorize(name, beautiful.fg),
    font = beautiful.font_name .. "12",
    align = "right",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local freq = wibox.widget({
    markup = colorize(frequency, beautiful.hab_freq),
    font = beautiful.font_name .. "10",
    align = "right",
    valign = "center",
    widget = wibox.widget.textbox,
  })

  local habit_entry = wibox.widget({
    id = graph_id,
    {
      {
        habit_name,
        freq,
        forced_width = dpi(125),
        layout = wibox.layout.fixed.vertical,
      },
      widget = wibox.container.place,
    },
    {
      id = "days",
      spacing = dpi(10),
      layout = wibox.layout.flex.horizontal,
    },
    spacing = dpi(20),
    layout = wibox.layout.fixed.horizontal,
  })

  local completion = habit_list[graph_id]["completion"]
  local days = habit_entry:get_children_by_id("days")[1]
  for day = 3, 0, -1 do

    -- Set vars based on completion status
    local checked, text_color, qty
    if completion[day] then
      checked = true
      text_color = beautiful.hab_check_fg
      qty = 0
    else
      checked = false
      text_color = beautiful.hab_check_fg
      qty = 1
    end

    -- Checkbox text is the first letter of the day of the week
    local i_days_ago = os.time() - (60 * 60 * 24 * day)
    local date = os.date("%a", i_days_ago)
    local checkbox_text = string.sub(tostring(date), 1, 1)

    -- Assemble checkbox
    local checkbox = wibox.widget({
      { -- Checkbox
        checked = checked,
        forced_height = dpi(20),
        border_width = dpi(0),
        check_shape = gears.shape.circle,
        check_color = beautiful.hab_check_bg,
        bg = beautiful.hab_uncheck_bg,
        paddings = dpi(0),
        shape = gears.shape.circle,
        widget = wibox.widget.checkbox,
      },
      { -- Overlay text (date)
        markup = colorize(checkbox_text, text_color),
        font = beautiful.font_name .. "11",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox,
      },
      layout = wibox.layout.stack,
    })

    -- Checkbox should toggle habit completion status when pressed
    checkbox:connect_signal("button::press", function()
      -- Update UI
      local cbox = checkbox.children[1]
      cbox.checked = not cbox.checked
      text_color = cbox.checked and beautiful.hab_check_fg
          or not cbox.checked and beautiful.hab_uncheck_fg
      local text = checkbox.children[2]
      text.markup = colorize(checkbox_text, text_color)

      -- Update data in cache and in Pixela
      local cboxdate = os.date("%Y%m") .. os.date("%d", i_days_ago)
      print("updating for day " .. date)
      pixela:update_pixela(graph_id, cboxdate, qty)
      pixela:update_cache(graph_id, cboxdate, qty)

      qty = not qty
    end) -- end checkbox connect signal

    -- Add individual checkbox to navtree and UI
    nav_habit:append(Habit:new(checkbox))
    days:add(checkbox)

  end -- end for i in days_ago

  -- Add entire habit to navtree and UI
  habit_widget.children[1]:add(habit_entry)
  nav_dash_habits:append(nav_habit)

end -- end create_habit_entry

----------------------------------------

habit_widget = wibox.widget({
  {
    spacing = dpi(10),
    layout = wibox.layout.fixed.vertical,
  },
  widget = wibox.container.place
})

local container = box(habit_widget, dpi(550), dpi(410), beautiful.dash_widget_bg)
nav_dash_habits.widget = Dashwidget:new(container)

pixela:connect_signal("update::habits", function(_, graph_id)
  local id = graph_id
  local name = habit_list[graph_id][1]
  local freq = habit_list[graph_id][2]
  create_habit_ui_entry(name, id, freq)
end)

return function()
  return nav_dash_habits, container
end
