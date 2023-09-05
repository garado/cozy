
-- █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█    █▀ █░█░█ █ ▀█▀ █▀▀ █░█ █▀▀ █▀█ 
-- ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀    ▄█ ▀▄▀▄▀ █ ░█░ █▄▄ █▀█ ██▄ █▀▄ 

local beautiful  = require("beautiful")
local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local notrofi = require("backend.cozy.notrofi")
local fzf = require("modules.fzf")

local MAX_ENTRIES = 8
local CLIENT_ENTRY_HEIGHT = dpi(30)
local client_list

--- @function gen_client_entry
local function gen_client_entry(c, index)
  local fg = c.urgent and beautiful.red[400] or beautiful.neutral[100]

  local tags = c:tags()
  local tag_text = tags[1] and tags[1].name or "?"

  local tag = wibox.widget({
    {
      {
        ui.textbox({ text = tag_text, font = beautiful.font_reg_xs }),
        left = dpi(4),
        right = dpi(4),
        widget = wibox.container.margin,
      },
      bg = beautiful.neutral[600],
      widget = wibox.container.background,
    },
    right = dpi(10),
    widget = wibox.container.margin,
  })

  local entry = wibox.widget({
    {
      {
        {
          tag,
          ui.textbox({ color = fg, text = c.class .. ": " }),
          ui.textbox({ color = fg, text = c.name }),
          layout = wibox.layout.fixed.horizontal,
        },
        margins = dpi(8),
        widget = wibox.container.margin,
      },
      bg = index == 1 and beautiful.primary[700] or beautiful.neutral[800],
      forced_width = dpi(1000),
      widget = wibox.container.background,
    },
    forced_height = CLIENT_ENTRY_HEIGHT,
    layout = wibox.layout.fixed.horizontal,
  })

  entry.client = c
  entry.bg = entry.children[1]
  entry.index = index

  entry:connect_signal("mouse::enter", function(self)
    self.bg.bg = beautiful.primary[700]
  end)

  entry:connect_signal("mouse::leave", function(self)
    self.bg.bg = beautiful.neutral[800]
  end)

  entry:connect_signal("button::press", function(self)
    self.client:jump_to()
  end)

  if index == 1 then notrofi.active_element = entry end

  return entry
end

--- @function update_clientlist
-- @brief Populates the client list based on user's text input.
local function update_clientlist(_, key, input)
  local clients = client.get()

  -- No input: Generate list of all clients
  if not input then
    for i = 1, MAX_ENTRIES do
      if i > #clients then return end
      local entry = gen_client_entry(clients[i], i)
      client_list:add(entry)
    end
    return
  end

  -- If there is input: fuzzy find

  -- Generate table to fzf through
  local comp_keywords = {}
  for _, c in ipairs(clients) do
    comp_keywords[#comp_keywords+1] = c.class
  end

  local matches = fzf.filter(input, comp_keywords, false)
  client_list:reset()
  for i = 1, #matches do
    if i > MAX_ENTRIES then return end
    local entry = gen_client_entry(clients[matches[i][1]], i)
    client_list:add(entry)
    if i == 1 then
      notrofi.active_element = entry
      notrofi.active_element:emit_signal("mouse::enter")
    end
  end
end

client_list = wibox.widget({
  forced_height = CLIENT_ENTRY_HEIGHT * MAX_ENTRIES,
  layout = wibox.layout.fixed.vertical,
})

--- @method switch_callback
-- @brief Regenerate client list. Called whenever notrofi switches to window switcher tab.
function client_list.switch_callback()
  client_list:reset()
  local clients = client.get()
  for i = 1, MAX_ENTRIES do
    if i > #clients then break end
    client_list:add( gen_client_entry(clients[i], i) )
  end
end

function client_list.keyreleased_callback(_, key, input)
  update_clientlist(_, key, input)
end

function client_list.exe_callback()
  notrofi.active_element.client:jump_to()
end

return client_list
