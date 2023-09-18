
-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄    █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀    █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ 

local cozy    = require("backend.cozy.cozy")
local gtable  = require("gears.table")
local gobject = require("gears.object")

local be = {}

--- @method create_popup_manager
-- @brief Set up signals etc for popup manager
function be.create_popup_manager(args)
  local deftbl = { children = {} }
  local t = gtable.crush(args.tbl or {}, deftbl)

  -- turn into a gobject
  local ret = gobject{}
  gtable.crush(ret, t, true)

  function ret:new()
    self.visible = false
    if ret.on_init then ret:on_init() end
  end

  cozy:add_popup(args.name)

  function ret:add_child(child_name)
    self.children[#self.children+1] = child_name
  end

  function ret:toggle()
    if self.visible then
      self:close()
    else
      self:open()
    end

    if t.on_toggle then ret:on_toggle() end
  end

  function ret:close()
    -- Close child popups
    for child in ipairs(self.children) do
      self:emit_signal(child.."::setstate::close")
    end

    self:emit_signal("setstate::close")
    self.visible = false

    if ret.on_close then ret:on_close() end
  end

  function ret:open()
    cozy:close_all_except(args.name)
    self:emit_signal("setstate::open")
    self.visible = true

    if ret.on_open then ret:on_open() end
  end

  ret:new()
  return ret
end

return be
