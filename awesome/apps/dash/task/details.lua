
-- █▀▄ █▀▀ ▀█▀ ▄▀█ █ █░░ █▀ 
-- █▄▀ ██▄ ░█░ █▀█ █ █▄▄ ▄█ 

-- Show more task details!

local beautiful   = require("beautiful")
local wibox       = require("wibox")
local xresources  = require("beautiful.xresources")
local gears       = require("gears")
local keynav      = require("modules.keynav")
local colorize    = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date
local dpi   = xresources.apply_dpi
local task  = require("core.system.task")

-- Information to add to details box
local entries = {
  "id",
  "entry", -- creation date
  "recur",
  "until",
  "wait",
  "link",
  "annotations",
}

local entries_fancy = {
  "ID",
  "Created",
  "Recur",
  "Until",
  "Hide until",
  "Link",
  "Annotations",
}

--- Creates wibox showing annotation data.
local function annotations()
  local label = wibox.widget({
    markup = colorize("Annotations", beautiful.fg_0),
    align  = "start",
    valign = "top",
    font   =  beautiful.font_reg_s,
    forced_width = dpi(120),
    widget = wibox.widget.textbox,
  })

  local annos = task.focused_task["annotations"]

  local ret = wibox.widget({
    label,
    {
      spacing = dpi(5),
      layout  = wibox.layout.fixed.vertical,
    },
    spacing = dpi(15),
    layout  = wibox.layout.fixed.horizontal,
    -------
    add_anno = function(self, i)
      local box = wibox.widget({
        markup = colorize(i .. '. ' .. annos[i]["description"], beautiful.fg_0),
        widget = wibox.widget.textbox,
      })
      self.children[2]:add(box)
    end
  })

  for i = 1, #annos do ret:add_anno(i) end

  return ret
end

local function entry(index)
  local field = entries[index]
  local text  = task.focused_task[field]
  if not text then return end
  if field == "annotations" then return annotations() end

  local field_display_text = entries_fancy[index]
  if field == "entry" then text = task:format_date(text) .. ' (' .. format_due_date(text) .. ')' end
  if field == "wait"  then text = task:format_date(text) end

  return wibox.widget({
    {
      markup = colorize(field_display_text, beautiful.fg_0),
      align  = "start",
      valign = "top",
      font   =  beautiful.font_reg_s,
      forced_width = dpi(120),
      widget = wibox.widget.textbox,
    },
    {
      markup = colorize(text, beautiful.fg_0),
      align  = "start",
      valign = "top",
      font   =  beautiful.font_reg_s,
      widget = wibox.widget.textbox,
    },
    spacing = dpi(15),
    layout  = wibox.layout.fixed.horizontal,
  })
end


local title = wibox.widget({
  {
    markup = colorize("Task details", beautiful.fg_0),
    font   = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
  },
  {
    markup = colorize("----------------", beautiful.fg_0),
    font   = beautiful.font_reg_s,
    widget = wibox.widget.textbox,
  },
  spacing = dpi(2),
  layout  = wibox.layout.fixed.vertical,
})

local details = wibox.widget({
  spacing = dpi(8),
  visible = false,
  layout  = wibox.layout.fixed.vertical,
  ----------
  update = function(self)
    self:reset()
    self:add(title)
    for i = 1, #entries do
      if task.focused_task[entries[i]] then
        local new_entry = entry(i)
        if new_entry then self:add(new_entry) end
      end
    end
  end
})

local function update_details()
  if not task.focused_task then return end
  details:update()
end

local function reset() details:reset() end

task:connect_signal("details::toggle", function()
  if details.visible then
    task:disconnect_signal("selected::task", update_details)
    task:disconnect_signal("selected::tag", reset)
    task:disconnect_signal("selected::project", reset)
  elseif not details.visible then
    task:connect_signal("selected::task", update_details)
    task:connect_signal("selected::tag", reset)
    task:connect_signal("selected::project", reset)
  end

  details.visible = not details.visible
end)

return wibox.widget({
  details,
  margins = dpi(20),
  widget = wibox.container.margin,
})
