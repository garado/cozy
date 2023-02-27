
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█    █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄    █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- Shown when adding or modifying tasks.

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi    = xresources.apply_dpi
local awful  = require("awful")
local wibox  = require("wibox")
local keynav = require("modules.keynav")
local ui     = require("helpers.ui")
local cpcore = require("core.cozy.calpopup")

local navigator, _ = keynav.navigator({
  root_children = {},
  root_keys = {
    ["Escape"] = function()
      cpcore:close()
    end,
  },
})

local function textfield(args)
  args = args or {}
  local font   = args.font or beautiful.font_reg_s
  local height = args.height
  local width  = args.width
  local align  = args.align or "left"

  return wibox.widget({
    {
      {
        font   = font,
        align  = align,
        widget = wibox.widget.textbox,
      },
      top    = dpi(5),
      bottom = dpi(5),
      right  = dpi(8),
      left   = dpi(8),
      widget = wibox.container.margin,
    },
    forced_height = height,
    forced_width  = width,
    bg = beautiful.red,
    widget = wibox.container.background,
  })
end

local function label(args)
  local icon  = args.icon or ""
  local _label = args.label or ""

  return wibox.widget({
    {
      markup = ui.colorize(icon, beautiful.fg_2),
      font   = beautiful.font_reg_s,
      align  = "center",
      widget = wibox.widget.textbox,
    },
    {
      markup = ui.colorize(_label, beautiful.fg_2),
      font   = beautiful.font_reg_s,
      align  = "center",
      widget = wibox.widget.textbox,
    },
    spacing = dpi(5),
    layout  = wibox.layout.fixed.horizontal,
  })
end

local titlebox = textfield({ height = dpi(50), width = dpi(400), font = beautiful.font_reg_m })

local locbox   = textfield({ height = dpi(30), width = dpi(400) })
local loclabel = label({ icon = "", label = "Location" })

local datebox   = textfield({ height = dpi(30), width = dpi(200) })
local stimebox  = textfield({ height = dpi(30), width = dpi(100) })
local etimebox  = textfield({ height = dpi(30), width = dpi(100) })
local datelabel = label({ icon = "", label = "Date" })

local title_accent_underline = wibox.widget({
  forced_width  = dpi(400),
  forced_height = dpi(2),
  bg     = beautiful.primary_0,
  widget = wibox.container.background,
})

-- Arranging the UI
local calpopup_content = wibox.widget({
  titlebox,
  ui.place(title_accent_underline),
  {
    datebox,
    stimebox,
    {
      markup = ui.colorize(" to ", beautiful.fg_0),
      font   = beautiful.font_reg_s,
      align  = "center",
      widget = wibox.widget.textbox,
    },
    etimebox,
    spacing = dpi(10),
    layout  = wibox.layout.fixed.horizontal,
  },
  { -- Location
    loclabel,
    locbox,
    widget = wibox.layout.fixed.horizontal,
  },
  spacing = dpi(20),
  layout  = wibox.layout.fixed.vertical,
  ------
  show_cal = function(self)
    self:insert(3, calendar)
  end,
  hide_cal = function(self)
    self:remove(3)
  end,
})

local calpopup = awful.popup({
  type = "splash",
  minimum_height = dpi(600),
  maximum_height = dpi(600),
  minimum_width  = dpi(450),
  maximum_width  = dpi(450),
  placement = awful.placement.centered,
  visible = false,
  ontop   = true,
  bg      = beautiful.dash_widget_bg,
  widget  = {
    calpopup_content,
    widget = wibox.container.place,
  },
})


-- █▀ █ █▀▀ █▄░█ ▄▀█ █░░ █▀ 
-- ▄█ █ █▄█ █░▀█ █▀█ █▄▄ ▄█ 

-- cpcore:connect_signal("calendar::show", function()
--   calendar:show_cal()
-- end)
-- 
-- cpcore:connect_signal("calendar::hide", function()
--   calendar:hide_cal()
-- end)

cpcore:connect_signal("setstate::open", function()
  calpopup.visible = true
  navigator:start()
  -- calpopup_content:show_cal()
end)

cpcore:connect_signal("setstate::close", function()
  calpopup.visible = false
  navigator:stop()
  -- calpopup_content:hide_cal()
end)

return function()
  return calpopup
end
