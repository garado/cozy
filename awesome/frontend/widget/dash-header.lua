
-- █▀▄ ▄▀█ █▀ █░█    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▄▀ █▀█ ▄█ █▀█    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local awful = require("awful")
local wibox = require("wibox")
local sbg   = require("frontend.widget.stateful-button-group")
local gtable = require("gears.table")

local header = {}

local function worker(user_args)
  local args = {
    header_text   = "Header Text",
    header_markup = nil,
  }
  gtable.crush(args, user_args)

  local header_text = ui.textbox({
    markup = args.header_markup,
    text   = args.header_text,
    align  = "left",
    font   = beautiful.font_light_xl,
  })

  local actions = wibox.widget({
    spacing = dpi(5),
    layout  = wibox.layout.fixed.horizontal,
  })

  header = wibox.widget({
    header_text,
    nil,
    {
      {
        actions,
        sbg,
        spacing = dpi(15),
        layout  = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    },
    layout = wibox.layout.align.horizontal,
  })

  function header:add_action(btn)
    self.children[#self.children].widget.children[1]:add(btn)
  end

  function header:add_sb(name, func)
    local _sbg = self.children[#self.children].widget.children[2]
    _sbg:add_btn(name, func)
  end

  return header
end

return setmetatable(header, { __call = function(_, ...) return worker(...) end })
