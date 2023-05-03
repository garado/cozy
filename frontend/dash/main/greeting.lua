
-- █▀▀ █▀█ █▀▀ █▀▀ ▀█▀ █ █▄░█ █▀▀ 
-- █▄█ █▀▄ ██▄ ██▄ ░█░ █ █░▀█ █▄█ 

local beautiful  = require("beautiful")
local dash = require("backend.state.dash")
local ui   = require("utils.ui")
local os   = require("os")

local greeting = ui.textbox({
  markup = ui.colorize("Good morning, ", beautiful.fg) ..
           ui.colorize("Alexis", beautiful.primary[400]),
  font   = beautiful.font_reg_xl,
  align  = "left",
})

function greeting:update()
  local mkup
  local hour = tonumber(os.date("%H"))
  if hour < 6 then
    mkup = ui.colorize("Having a late night, ", beautiful.fg) ..
           ui.colorize("Alexis?", beautiful.primary[400])
  elseif hour < 12 then
    mkup = ui.colorize("Good morning, ", beautiful.fg) ..
           ui.colorize("Alexis", beautiful.primary[400])
  elseif hour < 18 then
    mkup = ui.colorize("Good afternoon, ", beautiful.fg) ..
           ui.colorize("Alexis", beautiful.primary[400])
  else
    mkup = ui.colorize("Good evening, ", beautiful.fg) ..
           ui.colorize("Alexis", beautiful.primary[400])
  end
  greeting.markup = mkup
end

dash:connect_signal("setstate::open", greeting.update)

return greeting
