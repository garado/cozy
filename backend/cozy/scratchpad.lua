
-- █▀ █▀▀ █▀█ ▄▀█ ▀█▀ █▀▀ █░█ █▀█ ▄▀█ █▀▄ 
-- ▄█ █▄▄ █▀▄ █▀█ ░█░ █▄▄ █▀█ █▀▀ █▀█ █▄▀ 

-- Wrapper for Bling's scratchpad module because I want to control its state
-- the same way I control the state of Cozy's other popups.

local be = require("utils.backend")
local scratchpad = {}

function scratchpad:on_init()
  self.window = require("modules.bling").module.scratchpad {
    command = "kitty --class scratch --instance-group scratchpad --session sessions/scratchpad",
    rule = { instance = "scratch" },
    sticky = true,
    autoclose = true,
    floating = true,
    geometry = { x=360, y=90, height=900, width=1200 },
    reapply = true,
    dont_focus_before_close = true,
  }
end

function scratchpad:on_open()
  self.window:turn_on()
end

function scratchpad:on_close()
  self.window:turn_off()
end

return be.create_popup_manager({
  name = "scratchpad",
  tbl = scratchpad,
})
