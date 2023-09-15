
-- █▀▄ █▀▀ ▀█▀ ▄▀█ █ █░░ █▀ 
-- █▄▀ ██▄ ░█░ █▀█ █ █▄▄ ▄█ 

local ui    = require("utils.ui")
local dpi   = ui.dpi
local wibox = require("wibox")
local strutil = require("utils.string")
local task  = require("backend.system.task")

-- Define the fields we care about; all others ignored
local fields = { "id", "entry", "modified", "status", "due", "annotations", "rtype", "recur" }

--- @function gen_entry
-- @brief Create the UI for a detail entry.
local function gen_entry(title, content)
  return wibox.widget({
    ui.textbox({
      valign = "top",
      text  = title,
      width = dpi(100),
    }),
    ui.textbox({ text = content }),
    layout = wibox.layout.fixed.horizontal,
  })
end

local details = wibox.widget({
  spacing = dpi(4),
  layout  = wibox.layout.fixed.vertical,
})

local function gen_annotations(annotations)
  local ret = wibox.widget({
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
  })

  for i = 1, #annotations do
    local a = ui.textbox({
      text = strutil.dt_convert(annotations[i].entry, strutil.dt_format.iso, "%b %d %Y") .. ": " ..
             annotations[i].description
    })
    ret:add(a)
  end
  return ret
end

--- @method update
-- @brief Update details display to show information on the given task
-- @param t A task table directly from the `task export` command.
function details:update(t)
  details:reset()
  for i = 1, #fields do
    local field = fields[i]
    if t[field] then
      local content = t[field]
      if field == "modified" or field == "entry" then
        content = strutil.dt_convert(t[field], strutil.dt_format.iso, '%A %B %d %Y')
      end
      if field == "id" then field = "ID" end

      if field == "annotations" then
        local ugh = gen_entry("Annotations", "")
        ugh.children[2] = gen_annotations(content)
        details:add(ugh)
      else
        details:add(gen_entry(strutil.first_to_upper(field), content))
      end
    end
  end
end

function details:show() details.visible = true  end
function details:hide() details.visible = false end
function details:toggle() details.visible = not details.visible end

task:connect_signal("selected::task",    details.update)
task:connect_signal("selected::tag",     details.hide)
task:connect_signal("selected::project", details.hide)
task:connect_signal("details::toggle",   details.toggle)

return details
