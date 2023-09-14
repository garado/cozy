
-- █▀▄ ▄▀█ █▀ █░█    █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█
-- █▄▀ █▀█ ▄█ █▀█    █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄

-- To keep things looking nice and uniform, this is a widget
-- for the header of all the dashboard tabs.

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local ss    = require("frontend.widget.single-select")
local sbtn  = require("frontend.widget.stateful-button")
local btn    = require("frontend.widget.button")
local gtable = require("gears.table")
local yorha_header = require("frontend.widget.yorha.header")

local header = {}

local function worker(user_args)
  local args = {
    title_text    = "Title",
    subtitle_text = "",
    actions = {},
    pages = {},
  }
  gtable.crush(args, user_args or {})

  -- Assemble components
  local title = yorha_header({ text = args.title_text })

  local subtitle = ui.textbox({
    markup = args.subtitle_mkup,
    text   = args.subtitle_text,
    font   = beautiful.font_reg_m,
    color  = beautiful.neutral[300],
  })

  local actions = wibox.widget({
    spacing = dpi(5),
    layout  = wibox.layout.fixed.horizontal,
  })

  if args.actions then
    for i = 1, #args.actions do
      local act = btn({
        text = args.actions[i].text,
        func = args.actions[i].func,
      })
      actions:add(act)
    end
  end

  local pages = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
  })

  -- Set up single-select for pages in tab
  pages = ss({ layout = pages, autoset_first = true })

  if args.pages then
    for i = 1, #args.pages do
      local page = sbtn({
        text = args.pages[i].text,
        func = args.pages[i].func,
        set_no_shape = true,
      })
      pages:add_element(page)
    end
  end

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
        {
          pages,
          shape = ui.rrect(),
          widget = wibox.container.background,
        },
        spacing = dpi(15),
        layout  = wibox.layout.fixed.horizontal,
      },
      widget = wibox.container.place,
    },
    forced_height = dpi(100),
    layout = wibox.layout.align.horizontal,
  })

  -- Methods
  function header:clear_actions()
    actions:reset()
  end

  function header:add_action(_args)
    actions:add(btn({
      text = _args.text,
      func = _args.func,
    }))
  end

  function header:add_sb(text, func)
    local s = sbtn({
      text = text,
      func = func,
      set_no_shape = true,
    })
    pages:add_element(s)
  end

  function header:update_title(_args)
    if _args.text then
      title:update_text(_args.text)
    elseif _args.markup then
      title:update_text(_args.markup)
    end
  end

  function header:update_subtitle(_args)
    if _args.text then
      subtitle:update_text(_args.text)
    elseif _args.markup then
      subtitle.markup = _args.markup
    end
  end

  function header:get_actions()
    return actions.children
  end

  function header:get_pages()
    return pages.children
  end

  return header
end

return setmetatable(header, { __call = function(_, ...) return worker(...) end })
