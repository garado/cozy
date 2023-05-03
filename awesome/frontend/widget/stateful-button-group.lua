
-- █▀ █▄▄    █▀▀ █▀█ █▀█ █░█ █▀█ 
-- ▄█ █▄█    █▄█ █▀▄ █▄█ █▄█ █▀▀ 

-- A group of stateful buttons where only one button can be selected
-- at once.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local sbtn  = require("frontend.widget.stateful-button")

local sb_group = {}

local function worker(user_args)
  sb_group = wibox.widget({
    {
      {
        layout = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.margin,
    },
    shape  = ui.rrect(),
    bg     = beautiful.neutral[800],
    widget = wibox.container.background,
  })

  function sb_group:get_buttons()
    return self.children[1].widget.children
  end

  function sb_group:add_btn(btn_name, func)
    local w = sbtn({
      text = btn_name,
      name = btn_name,
      press_func = function(_self)
        _self.parent:emit_signal("child::press", _self.index)
      end
    })
    w.parent = self
    w.index  = #self:get_buttons() + 1

    self.children[1].widget:add(w)

    if #self:get_buttons() == 1 then
      self.current_selection_idx = 1
      w.selected = true
      w:update()
    end
  end

  sb_group:connect_signal("child::press", function(self, idx)
    if idx ~= self.current_selection_idx then
      self:get_buttons()[self.current_selection_idx].selected = false
      self:get_buttons()[self.current_selection_idx]:update()
      self:get_buttons()[idx].selected = true
      self:get_buttons()[idx]:update()
      self.current_selection_idx = idx
    end
  end)

  function sb_group:select(idx)
  end

  return sb_group
end

return setmetatable(sb_group, { __call = function(_, ...) return worker(...) end })
