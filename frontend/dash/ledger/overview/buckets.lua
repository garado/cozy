
-- █▄▄ █░█ █▀▀ █▄▀ █▀▀ ▀█▀ █▀ 
-- █▄█ █▄█ █▄▄ █░█ ██▄ ░█░ ▄█ 

-- View savings categories (buckets)

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")

local buckets = ui.textbox({
  text  = "Buckets",
  align = "center",
  font  = beautiful.font_med_m,
})

return ui.dashbox(
  ui.place(buckets),
  dpi(500), -- width
  dpi(2000)  -- height
)
