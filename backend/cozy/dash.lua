
-- █▀▄ ▄▀█ █▀ █░█ 
-- █▄▀ █▀█ ▄█ █▀█ 

-- Manages state for dashboard, along with other miscellaneous variables.

local be = require("utils.backend")

local dash = {}

function dash:set_tab(tabnum)
  self:emit_signal("tab::set", tabnum)
  self.curtab = tabnum
end

function dash:on_init()
  self.date = os.date("%d")
end

function dash:on_open()
  if os.date("%d") ~= self.date then
    self:emit_signal("date::changed")
  end
end

return be.create_popup_manager({
  tbl = dash,
  name = "dash",
})
