
-- █▀▄ ▄▀█ █▀ █░█    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▄▀ █▀█ ▄█ █▀█    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

-- To keep things looking nice and uniform, this is a widget
-- for the header of all the dashboard tabs. It has a title/
-- subtitle and action/navigation buttons.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local sbg   = require("frontend.widget.stateful-button-group")
local gtable = require("gears.table")

local header = {}

local function worker(user_args)
  local args = {
    title_text    = "Title",
    subtitle_text = "Subtitle",
  }
  gtable.crush(args, user_args or {})

  -- Assemble components
  local title = ui.textbox({
    markup = args.title_mkup,
    text   = args.title_text,
    align  = "left",
    font   = beautiful.font_reg_xl,
  })

  local subtitle = ui.textbox({
    markup = args.subtitle_mkup,
    text   = args.subtitle_text,
    align  = "left",
    font   = beautiful.font_reg_m,
    color  = beautiful.neutral[300],
  })

  local actions = wibox.widget({
    spacing = dpi(5),
    layout  = wibox.layout.fixed.horizontal,
  })

  local nav = sbg({
    set_no_shape = true,
  })

  header = wibox.widget({
    {
      title,
      subtitle,
      spacing = dpi(15),
      layout  = wibox.layout.fixed.horizontal,
    },
    nil,
    {
      {
        actions,
        nav,
        spacing = dpi(15),
        layout  = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    },
    layout = wibox.layout.align.horizontal,
  })

  -- Methods
  function header:clear_actions()
    self.children[#self.children].widget.children[1]:reset()
  end

  function header:add_action(btn)
    self.children[#self.children].widget.children[1]:add(btn)
  end

  function header:add_sb(name, func)
    local _sbg = self.children[#self.children].widget.children[2]
    _sbg:add_btn(name, func)
  end

  function header:update_title(_args)
    if _args.text then
      title:update_text(_args.text)
    elseif _args.markup then
      title.markup = _args.markup
    end
  end

  function header:update_subtitle(_args)
    if _args.text then
      subtitle:update_text(_args.text)
    elseif _args.markup then
      subtitle.markup = _args.markup
    end
  end

  return header
end

return setmetatable(header, { __call = function(_, ...) return worker(...) end })
