
-- █▀ █▄▄    █▀▀ █▀█ █▀█ █░█ █▀█ 
-- ▄█ █▄█    █▄█ █▀▄ █▄█ █▄█ █▀▀ 

-- A group of stateful buttons where only one button can be selected
-- at once.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local sbtn  = require("frontend.widget.stateful-button")
local gtable = require("gears.table")
local keynav = require("modules.keynav")

local sb_group = {}

local function worker(user_args)
  local args = {
    layout   = "horizontal",
    spacing  = dpi(0),
    group_bg = beautiful.neutral[800],
    btn_shape = ui.rrect(),
    autoselect_first = true,
    keynav   = false,
    name = nil,
  }
  gtable.crush(args, user_args or {})
  if args.set_no_shape then args.btn_shape = nil end

  local _layout = wibox.layout.fixed[args.layout]

  sb_group = wibox.widget({
    {
      {
        spacing = args.spacing,
        layout  = _layout,
      },
      widget = wibox.container.margin,
    },
    shape  = ui.rrect(),
    bg     = args.group_bg,
    widget = wibox.container.background,
  })

  sb_group.autoselect_first = args.autoselect_first
  sb_group.current_selection_idx = 0

  -- Set up keynav area if necessary
  if args.keynav then
    sb_group.keynav = true
    sb_group.area = keynav.area({
      name = "nav_sbg" .. (args.name and ('_' .. args.name) or "")
    })
  end

  function sb_group:get_buttons()
    return self.children[1].widget.children
  end

  -- Add a stateful button to this stateful button group
  function sb_group:add_btn(btn_name, func)
    local w = sbtn({
      width  = args.width,
      height = args.height,
      text = btn_name,
      name = btn_name,
      shape = args.btn_shape,
      set_no_shape = args.set_no_shape,
      press_func = function(_self)
        _self.parent:emit_signal("child::press", _self.index)
        if func then func() end
      end
    })
    w.parent = self
    w.index  = #self:get_buttons() + 1
    w.selected = false

    self.children[1].widget:add(w)

    if self.autoselect_first and #self:get_buttons() == 1 then
      self.current_selection_idx = 1
      w.selected = true
    end

    -- Create navitem if necessary
    if self.keynav then
      local nav_sbtn = keynav.navitem.btn({
        widget = w
      })
      nav_sbtn.widget = w
      self.area:append(nav_sbtn)
    end

    w:update()
  end

  function sb_group:init()
    self:connect_signal("child::press", function(_, idx)
      if idx ~= self.current_selection_idx then
        if self.current_selection_idx ~= 0 then
          self:get_buttons()[self.current_selection_idx].selected = false
          self:get_buttons()[self.current_selection_idx]:update()
        end

        self:get_buttons()[idx].selected = true
        self:get_buttons()[idx]:update()
        self.current_selection_idx = idx
      end
    end)
    return self
  end

  function sb_group:get_name_at_idx(idx)
    return self:get_buttons()[idx].children[1].widget.text
  end

  function sb_group:reset()
    self.current_selection_idx = 0
    local btns = self.children[1].widget
    btns:reset()
    if self.area then self.area:clear() end
  end

  return sb_group:init()
end

return setmetatable(sb_group, { __call = function(_, ...) return worker(...) end })
