-- █▄░█ █▀█ ▀█▀    █▀█ █▀█ █▀▀ █
-- █░▀█ █▄█ ░█░    █▀▄ █▄█ █▀░ █

-- It's not Rofi, but it's Rofi.
-- https://github.com/adi1090x/rofi/ (Type 7 Img 10)

-- Window switcher and app launcher with implementation heavily inspired by
-- bling's but modified to suit my aesthetic.

local ui = require("utils.ui")
local dpi = ui.dpi
local gfs = require("gears.filesystem")
local awful = require("awful")
local wibox = require("wibox")
local notrofi = require("backend.cozy.notrofi")
local beautiful = require("beautiful")
local keynav = require("modules.keynav")
local fzf = require("modules.fzf")
local Gio = require("lgi").Gio
local strutil = require("utils.string")

local CFG_DIR = gfs.get_configuration_dir()
local MAX_ENTRIES = 8
local APP_ENTRY_HEIGHT = dpi(30)

local all_entries = {}
local comp_keywords = {}
local first_app = nil

local navigator, nav_root = keynav.navigator({
  stop_key = "Mod1",
  autofocus = true,
})

-- █▀▀ █▀█ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ █▀▄
-- █▀░ █▀▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ █▄▀

--- @function gen_app_entry
local function gen_app_entry(app)
  local entry = wibox.widget({
    {
      {
        ui.textbox({ text = app.name }),
        margins = dpi(8),
        widget = wibox.container.margin,
      },
      bg = beautiful.neutral[800],
      forced_width = dpi(1000),
      widget = wibox.container.background,
    },
    forced_height = APP_ENTRY_HEIGHT,
    layout = wibox.layout.fixed.horizontal,
  })

  entry.app = app
  entry.bg = entry.children[1]

  entry:connect_signal("mouse::enter", function(self)
    self.bg.bg = beautiful.primary[700]
  end)

  entry:connect_signal("mouse::leave", function(self)
    self.bg.bg = beautiful.neutral[800]
  end)

  entry:connect_signal("button::press", function(self)
    if self.app.terminal then
    else
      awful.spawn(self.app.executable)
      notrofi:close()
    end
  end)

  return entry
end

local img = wibox.widget({
  image = CFG_DIR .. "theme/colorschemes/mountain/nrofi",
  resize = true,
  forced_width = dpi(200),
  widget = wibox.widget.imagebox,
})

local promptbox = wibox.widget({
  text = "Search",
  font = beautiful.font_reg_s,
  widget = wibox.widget.textbox,
})

local promptbox_colorized = wibox.container.background()
promptbox_colorized:set_widget(promptbox)
promptbox_colorized:set_fg(beautiful.neutral[100])

local search = wibox.widget({
  { -- Icon
    {
      ui.textbox({
        text = "",
        align = "center",
      }),
      margins = dpi(8),
      widget = wibox.container.margin,
    },
    shape = ui.rrect(),
    bg = beautiful.neutral[600],
    widget = wibox.container.background,
  },
  { -- Searchbar
    {
      promptbox_colorized,
      margins = dpi(8),
      widget = wibox.container.margin,
    },
    shape = ui.rrect(),
    bg = beautiful.neutral[600],
    forced_width = dpi(200),
    widget = wibox.container.background,
  },
  spacing = dpi(4),
  layout = wibox.layout.fixed.horizontal,
})

-- App entries
local app_list = wibox.widget({
  forced_height = APP_ENTRY_HEIGHT * MAX_ENTRIES,
  layout = wibox.layout.fixed.vertical,
  -----
  area = keynav.area({
    name = "nav_applist",
  })
})

local app_list_container = wibox.widget({
  {
    app_list,
    margins = dpi(20),
    widget = wibox.container.margin,
  },
  bg = beautiful.neutral[800],
  widget = wibox.container.background,
})

local options = wibox.widget({
  {
    {
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.margin,
  },
  widget = wibox.container.background,
})

local widget = wibox.widget({
  {
    img,
    ui.place(search),
    widget = wibox.layout.stack,
  },
  app_list_container,
  options,
  layout = wibox.layout.fixed.vertical,
})

local nrofi = awful.popup({
  type          = "splash",
  minimum_width = dpi(450),
  maximum_width = dpi(450),
  bg            = beautiful.neutral[900],
  shape         = ui.rrect(),
  ontop         = true,
  visible       = false,
  placement     = awful.placement.centered,
  widget        = widget
})


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀

--- @function generate_apps
-- @brief Generate a list of all apps that can possibly show within launcher.
local function generate_apps()
  all_entries = {}
  comp_keywords = {}
  local app_info = Gio.AppInfo
  local apps = app_info.get_all()

  for _, app in ipairs(apps) do
    if app.should_show(app) then
      local name = app_info.get_name(app)

      comp_keywords[#comp_keywords+1] = name

      all_entries[#all_entries+1] = {
        name = name,
        executable = app_info.get_executable(app),
      }
    end
  end
end
generate_apps()

--- @function update_applist
-- @brief Updates the app list based on the user's current text input.
-- Called on every keypress.
local function update_applist(_, key, input)
  if key == "Escape" then notrofi:close() end
  if input == "" then return end

  local matches = fzf.filter(input, comp_keywords, false)

  app_list:reset()
  app_list.area:clear()

  for i = 1, #matches do
    if i > MAX_ENTRIES then return end
    local entry = gen_app_entry( all_entries[matches[i][1]] )
    app_list:add(entry)
    app_list.area:append(entry)

    if i == 1 then first_app = entry end
  end
end

--- @function prompt
-- @brief Get user's input
local function prompt()
  awful.prompt.run {
    font         = beautiful.font_reg_s,
    prompt       = "",
    text         = "",
    bg_cursor    = beautiful.primary[400],
    textbox      = promptbox,
    keypressed_callback = update_applist,
    exe_callback = function()
      first_app:emit_signal("button::press")
    end,
  }
end

nav_root:append(app_list.area)

for i = 1, MAX_ENTRIES do
  local entry = gen_app_entry(all_entries[i])
  app_list:add(entry)
  app_list.area:append(entry)
end

notrofi:connect_signal("setstate::open", function()
  nrofi.visible = true
  navigator:start()
  prompt()
end)

notrofi:connect_signal("setstate::close", function()
  nrofi.visible = false
  navigator:stop()

  -- To kill the prompt
  awful.keygrabber.stop()
end)
