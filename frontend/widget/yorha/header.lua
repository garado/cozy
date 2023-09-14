
-- █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

-- Text with... shadowy text

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local wibox = require("wibox")

local header = {}

local function worker(args)
  local top = ui.textbox({
    text = args.text:upper(),
    font = beautiful.font_reg_xl,
    color = beautiful.neutral[100],
  })


  local bottom = ui.textbox({
    text = args.text:upper(),
    font = beautiful.font_reg_xl,
    color = beautiful.neutral[500],
  })

  local widget = wibox.widget({
    bottom,
    top,
    horizontal_offset = ui.dpi(-4),
    vertical_offset   = ui.dpi(-3),
    layout = wibox.layout.stack,
  })

  function widget:update_text(text)
    -- text = text:gsub("<[^>]+>", "") -- strip pango
    -- top:update_text(text:upper())
    -- bottom:update_text(text:upper())
  end

  return widget
end

return setmetatable(header, { __call = function(_, ...) return worker(...) end })
