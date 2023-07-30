
-- █▄▄ █░█ █▀▀ █▄▀ █▀▀ ▀█▀ █▀ 
-- █▄█ █▄█ █▄▄ █░█ ██▄ ░█░ ▄█ 

-- View savings categories (buckets)

local beautiful = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")

local bucket_data = {
  {
    "Emergency fund",
    "",
    1157,
    3000,
    "6 months",
  },
  {
    "Tim Henson signature nylon",
    "",
    0,
    699,
    "1 year",
  },
  {
    "Next trip",
    "",
    0,
    500,
    "1 year",
  },
}

--- @method gen_bucket
-- @param data { title, icon, amount, goal }
local function gen_bucket(data)
  local TITLE = 1
  local ICON  = 2
  local AMNT  = 3
  local GOAL  = 4
  local DUE   = 5

  local icon = wibox.widget({
    {
      {
        ui.textbox({
          text = data[ICON],
          font = beautiful.font_reg_s,
          color  = beautiful.primary[700],
        }),
        widget = wibox.container.place,
      },
      bg = beautiful.primary[100],
      shape = ui.rrect(),
      forced_height = dpi(30),
      forced_width  = dpi(30),
      widget = wibox.container.background,
    },
    widget = wibox.container.place,
  })

  local label = wibox.widget({
    ui.textbox({
      text = data[TITLE],
      font = beautiful.font_reg_m,
    }),
    ui.textbox({
      text = data[AMNT] .. ' / ' .. data[GOAL] .. " · " .. data[DUE] .. " left",
      font = beautiful.font_reg_s,
      color = beautiful.neutral[300],
    }),
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  })

  local bar = wibox.widget({
    value = data[AMNT],
    max_value = data[GOAL],
    forced_height = dpi(10),
    shape = ui.rrect(dpi(3)),
    color = beautiful.primary[200],
    background_color = beautiful.neutral[700],
    widget = wibox.widget.progressbar,
  })

  return wibox.widget({
    {
      icon,
      label,
      spacing = dpi(12),
      layout  = wibox.layout.fixed.horizontal,
    },
    bar,
    forced_width = dpi(330),
    spacing = dpi(8),
    layout = wibox.layout.fixed.vertical,
  })
end

local content = wibox.widget({
  ui.textbox({
    text  = "Buckets",
    align = "center",
    font  = beautiful.font_med_m,
  }),
  ui.vpad(dpi(-10)),
  spacing = dpi(25),
  layout = wibox.layout.fixed.vertical,
})

for i = 1, #bucket_data do
  content:add(gen_bucket(bucket_data[i]))
end

return ui.dashbox(
  ui.place(content),
  dpi(500), -- width
  dpi(340)  -- height
)
