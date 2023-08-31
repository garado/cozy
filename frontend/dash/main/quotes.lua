
-- █▀█ █░█ █▀█ ▀█▀ █▀▀ █▀ 
-- ▀▀█ █▄█ █▄█ ░█░ ██▄ ▄█ 

local beautiful  = require("beautiful")
local ui = require("utils.ui")
local dpi = ui.dpi
local wibox = require("wibox")
local conf = require("cozyconf")
local dash = require("backend.cozy.dash")

local text = ui.textbox({
  text = "Everything you want is on the other side of fear.",
  align = "center",
  font = beautiful.font_reg_m,
})

local attribution = ui.textbox({
  text = "Jack Canfield",
  align = "center",
  color = beautiful.neutral[400],
  font = beautiful.font_reg_s,
})

local quote = wibox.widget({
  text,
  attribution,
  spacing = dpi(4),
  layout = wibox.layout.fixed.vertical,
})

dash:connect_signal("setstate::close", function()
  local i = math.random(1, #conf.quotes)
  text:update_text(conf.quotes[i][1])
  attribution:update_text(conf.quotes[i][2])
end)

return ui.dashbox_v2(quote)
