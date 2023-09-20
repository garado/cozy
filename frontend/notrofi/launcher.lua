
-- ▄▀█ █▀█ █▀█    █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█ █▀▀ █▀█ 
-- █▀█ █▀▀ █▀▀    █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local Gio = require("lgi").Gio
local awful = require("awful")
local fzf = require("modules.fzf")
local wibox = require("wibox")
local notrofi = require("backend.cozy").notrofi
local math = math

local MAX_ENTRIES = 8
local APP_ENTRY_HEIGHT = dpi(30)

local app_list
local all_entries = {}
local comp_keywords = {}

-- Generate list of all possible app search results
local app_info = Gio.AppInfo
local apps = app_info.get_all()
for _, app in ipairs(apps) do
  if app.should_show(app) then
    local name = app_info.get_name(app)
    local icon = app_info.get_icon(app)

    comp_keywords[#comp_keywords + 1] = name

    all_entries[#all_entries + 1] = {
      name = name,
      icon = icon,
      executable = app_info.get_executable(app),
    }
  end
end

--- @function gen_app_entry
-- @brief Generate widget for an app entry
local function gen_app_entry(app, index)
  if not app then return end

  local entry = wibox.widget({
    {
      {
        {
          ui.textbox({ text = app.name }),
          layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(8),
        widget = wibox.container.margin,
      },
      bg = index == 1 and beautiful.primary[700] or beautiful.neutral[800],
      forced_width = dpi(1000),
      widget = wibox.container.background,
    },
    forced_height = APP_ENTRY_HEIGHT,
    layout = wibox.layout.fixed.horizontal,
  })

  entry.app = app
  entry.bg = entry.children[1]
  entry.index = index

  entry:connect_signal("mouse::enter", function(self)
    self.bg.bg = beautiful.primary[700]
  end)

  entry:connect_signal("mouse::leave", function(self)
    self.bg.bg = beautiful.neutral[800]
  end)

  entry:connect_signal("button::press", function(self)
    if self.app.terminal then
    else
      awful.spawn.easy_async_with_shell(self.app.executable, function() end)
      notrofi:close()
    end
  end)

  if index == 1 then notrofi.active_element = entry end

  return entry
end

--- @function update_applist
-- @brief Update applist based on user input.
local function update_applist(_, key, input)
  -- Generate list of all clients
  if not input then
    for i = 1, math.min(#all_entries, MAX_ENTRIES) do
      local entry = gen_app_entry(all_entries[i], i)
      app_list:add(entry)
    end
    return
  end

  local matches = fzf.filter(input, comp_keywords, false)
  app_list:reset()
  for i = 1, #matches do
    if i > MAX_ENTRIES then return end
    local entry = gen_app_entry(all_entries[matches[i][1]], i)
    app_list:add(entry)
    if i == 1 then
      notrofi.active_element = entry
      notrofi.active_element:emit_signal("mouse::enter")
    end
  end
end

-- App entries
app_list = wibox.widget({
  forced_height = APP_ENTRY_HEIGHT * MAX_ENTRIES,
  layout = wibox.layout.fixed.vertical,
})

for i = 1, math.min(#all_entries, MAX_ENTRIES) do
  local entry = gen_app_entry(all_entries[i])
  app_list:add(entry)
end

--- @method switch_callback
-- @brief Regenerate app list. Called whenever notrofi switches to window switcher tab.
function app_list.switch_callback()
  update_applist()
end

function app_list.keyreleased_callback(_, key, input)
  update_applist(_, key, input)
end

function app_list.exe_callback()
  if notrofi.active_element then
    notrofi.active_element:emit_signal("button::press")
  end
end

return app_list
