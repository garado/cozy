
-- █░█ █▀▀ ▄▀█ █▀▄ █▀▀ █▀█ 
-- █▀█ ██▄ █▀█ █▄▀ ██▄ █▀▄ 

-- Completion progress bar and other stuff

local beautiful = require("beautiful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local animation = require("modules.animation")
local helpers = require("helpers")
local textbox = require("ui.widgets.text")
local colorize = require("helpers.ui").colorize_text
local format_due_date = require("helpers.dash").format_due_date
local task = require("core.system.task")

-----

-- █░█ █ 
-- █▄█ █ 

local accent = beautiful.random_accent_color()

local name = wibox.widget({
  markup = colorize("Project name", accent),
  font = beautiful.alt_font .. "25",
  halign = "left",
  valign = "center",
  widget = wibox.widget.textbox,
})

local subheader = textbox({
  text = "Tag",
  color = beautiful.fg,
  font = beautiful.font,
  size = 10,
  halign = "left",
})

local percent_completion = wibox.widget({
  markup = colorize("0%", beautiful.fg),
  font = beautiful.alt_font .. "Light 25",
  halign = "right",
  valign = "center",
  widget = wibox.widget.textbox,
})

local progress_bar = wibox.widget({
  color = accent,
  background_color = beautiful.bg_l3,
  value = 0,
  max_value = 100,
  border_width = dpi(0),
  forced_width = dpi(280),
  forced_height = dpi(5),
  widget = wibox.widget.progressbar,
})

-- Update bar with completion percentage
-- local markup = colorize(percent.."%", beautiful.fg)
-- percent_completion:set_markup_silently(markup)

-- Progress bar animations
local progress_bar_animation = animation:new({
  duration = 1,
  value = 0,
  easing = animation.easing.inOutExpo,
  reset_on_stop = true,
  update = function(self, pos)
    progress_bar.value = dpi(pos)
  end
})

--progress_bar_animation:set(percent)

-----

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

task:connect_signal("selected::project", function(_, project)
  local tag = task:get_focused_tag()
  accent = beautiful.random_accent_color()

  -- print('HEADER')
  -- print(tag)
  -- print(project)

  if project == "(none)" or project == "noproj" then
    project = "No project"
  end

  local name_text = project:gsub("^%l", string.upper)
  name:set_markup_silently(colorize(name_text, accent))

  local pending = #task:get_pending_tasks(tag, project)
  local total = task:get_total_tasks(tag, project)
  local rem = pending.."/"..total.." REMAINING"
  local text = string.upper(tag).." - "..rem
  local markup = colorize(text, beautiful.fg)
  subheader:set_markup_silently(markup)

  local percent = task:get_proj_completion_percentage(tag, project)
  progress_bar.value = percent
  progress_bar.color = accent

  markup = colorize(percent.."%", beautiful.fg)
  percent_completion:set_markup_silently(markup)
end)

return tasklist_header
