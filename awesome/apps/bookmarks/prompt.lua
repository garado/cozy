
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local awful = require("awful")
local wibox = require("wibox")
local ui    = require("helpers.ui")
local bmcore = require("core.cozy.bookmarks")
local bmarks = require("cozyconf.bookmarks")
local fzy = require("modules.fzy_lua")

-- █░█ █ 
-- █▄█ █ 

local prompt = wibox.widget({
  {
    font   = beautiful.altfont_reg_s,
    markup = ui.colorize_text("alexis@andromeda ", beautiful.primary_0),
    align  = "center",
    widget = wibox.widget.textbox,
  },
  {
    font   = beautiful.altfont_reg_s,
    markup = ui.colorize_text("> ", beautiful.fg_0),
    align  = "center",
    widget = wibox.widget.textbox,
  },
  layout = wibox.layout.fixed.horizontal,
})

local prompt_textbox = wibox.widget.textbox()
local prompt_color = wibox.container.background()
prompt_color:set_widget(prompt_textbox)
prompt_color:set_fg(beautiful.fg_0)


-- █▄▄ ▄▀█ █▀▀ █▄▀ █▀▀ █▄░█ █▀▄ 
-- █▄█ █▀█ █▄▄ █░█ ██▄ █░▀█ █▄▀ 

-- returns just the titles
local function find_titles(t, res)
  if not res then res = {} end
  for _, v in pairs(t) do
    if type(v) == "table" then
      find_titles(v, res)
    end

    if v.title then
      res[#res+1] = v.title
    end
  end
  return res
end

local function title_completion(command_before_comp, cur_pos_before_comp, ncomp)
  local titles = find_titles(bmarks)
  return awful.completion.generic(command_before_comp, cur_pos_before_comp, ncomp, titles)
end

-- Start prompt
local function promptme()
  bmcore.titles = find_titles(bmarks)
  awful.prompt.run {
    textbox = prompt_textbox,
    fg      = beautiful.fg_0,
    font    = beautiful.altfont_reg_s,
    bg_cursor = beautiful.primary_0,
    changed_callback = function(command)
      bmcore.curmatches = fzy.filter(command, bmcore.titles)
      for _, data in pairs(bmcore.data) do
        data[bmcore.WIBOX]:set_fg(beautiful.bg_5)
      end

      for i = 1, #bmcore.curmatches do
        local title = bmcore.titles[bmcore.curmatches[i][1]]
        bmcore.data[title][bmcore.WIBOX]:set_fg(beautiful.fg_0)
      end
    end,
    completion_callback = title_completion,
    exe_callback = function(input)
      local cmd = 'xdg-open "'.. bmcore.data[input][bmcore.LINK] ..'"'
      awful.spawn.easy_async_with_shell(cmd, function() end)
      bmcore:close()
    end
  }
end

bmcore:connect_signal("setstate::open", promptme)

return {
  prompt,
  prompt_color,
  forced_height = dpi(30),
  layout  = wibox.layout.fixed.horizontal,
}
