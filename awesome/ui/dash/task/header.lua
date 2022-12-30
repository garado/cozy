
-- █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

-- Displays project completion statistics

local beautiful   = require("beautiful")
local wibox       = require("wibox")
local xresources  = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local animation   = require("modules.animation")
local colorize    = require("helpers.ui").colorize_text
local task        = require("core.system.task")

-- █░█ █ 
-- █▄█ █ 

local name = wibox.widget({
  markup = colorize("Project name", beautiful.fg),
  font   = beautiful.alt_large_font,
  halign = "left",
  valign = "center",
  widget = wibox.widget.textbox,
})

local subheader = wibox.widget({
  markup  = colorize("Tag", beautiful.fg),
  color   = beautiful.fg,
  font    = beautiful.base_xsmall_font,
  halign  = "left",
  widget = wibox.widget.textbox,
})

local percent_completion = wibox.widget({
  markup = colorize("0%", beautiful.fg),
  font   = beautiful.alt_large_font,
  halign = "right",
  valign = "center",
  widget = wibox.widget.textbox,
})

local progress_bar = wibox.widget({
  color = beautiful.fg,
  background_color = beautiful.bg_l3,
  value = 0,
  max_value = 100,
  border_width = dpi(0),
  forced_width = dpi(280),
  forced_height = dpi(5),
  widget = wibox.widget.progressbar,
})

-- Progress bar animations
-- local progress_bar_animation = animation:new({
--   duration = 1,
--   value = 0,
--   easing = animation.easing.inOutExpo,
--   reset_on_stop = true,
--   update = function(self, pos)
--     progress_bar.value = dpi(pos)
--   end
-- })

--progress_bar_animation:set(percent)

-- Put everything together
local tasklist_header = wibox.widget({
  {
    {
      name,
      subheader,
      layout = wibox.layout.fixed.vertical
    },
    nil,
    percent_completion,
    layout = wibox.layout.align.horizontal,
  },
  progress_bar,
  spacing = dpi(5),
  layout = wibox.layout.fixed.vertical
})

-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

local function update_header(tag, project)
  local accent = task:get_accent(tag, project)
  if not accent then
    accent = beautiful.random_accent_color()
    task:set_accent(tag, project, accent)
  end

  if project == "(none)" or project == "noproj" then
    project = "No project"
  end

  -- Project name
  local name_text = project:gsub("^%l", string.upper)
  name:set_markup_silently(colorize(name_text, accent))

  -- Completion statistics text
  local pending = #task:get_pending_tasks(nil, project)
  local total   = task:get_total_tasks(tag, project)
  local rem     = pending.."/"..total.." REMAINING"
  local text    = string.upper(tag).." - "..rem
  local markup  = colorize(text, beautiful.fg)
  subheader:set_markup_silently(markup)

  -- Progress bar
  local percent = task:get_proj_completion_percentage(tag, project)
  progress_bar.value = percent
  progress_bar.color = accent

  -- Completion percentage
  markup = colorize(percent.."%", beautiful.fg)
  percent_completion:set_markup_silently(markup)
end

task:connect_signal("header::update", function(_, tag, project)
  update_header(tag, project)
end)

return tasklist_header
