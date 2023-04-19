
-- █▀█ █▀█ █▀█ █▀▄▀█ █▀█ ▀█▀ 
-- █▀▀ █▀▄ █▄█ █░▀░█ █▀▀ ░█░ 

local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi   = xresources.apply_dpi
local awful = require("awful")
local wibox = require("wibox")
local ui    = require("helpers.ui")
local bm = require("core.cozy.bookmarks")
local bmarks = require("cozyconf.bookmarks")
local fzy = require("modules.fzy_lua")
local completion = require("apps.bookmarks.fzf-completion")

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

-- Iterate through bookmarks and create list of titles
local function find_titles(t, res)
  if not res then res = {} end
  for _, links in pairs(t) do
    for i = 1, #links do
      res[#res+1] = links[i][bm._TITLE]
    end
  end
  return res
end

-- Tab completion function
local function tab_complete(command_before_comp, cur_pos_before_comp, ncomp)
  return completion.fzf(command_before_comp, cur_pos_before_comp, ncomp, bm.titles)
end

-- Function to execute whenever the prompt input changes
-- Fuzzy-finds and highlights possible matches
local function changed_callback(command)
  bm.curmatches = fzy.filter(command, bm.titles)

  if command == "" then
    bm.content:set_all_fg(beautiful.fg_0)
    return
  else
    bm.content:set_all_fg(beautiful.bg_5)
  end

  for i = 1, #bm.curmatches do

    local title = bm.titles[bm.curmatches[i][1]]
    for _, links in pairs(bmarks) do
      for j = 1, #links do
        if links[j][bm._TITLE] == title then
          links[j][bm._WIBOX]:set_fg(beautiful.fg_0)
          goto continue
        end
      end
      ::continue::
    end

  end

end

-- Function to execute when pressing Enter on prompt
local function exe_callback(input)
  for _, links in pairs(bmarks) do
    for i = 1, #links do
      if links[i][bm._TITLE] == input then
        local link = links[i][bm._LINK]
        local cmd = 'xdg-open "'.. link ..'"'
        awful.spawn.easy_async_with_shell(cmd, function() end)
        bm:close()
        break
      end
    end
  end
end

-- Start prompt
local function promptme()
  bm.content:set_all_fg(beautiful.fg_0)
  bm.titles = find_titles(bmarks)
  awful.prompt.run {
    textbox = prompt_textbox,
    fg      = beautiful.fg_0,
    font    = beautiful.altfont_reg_s,
    bg_cursor = beautiful.primary_0,
    exe_callback = exe_callback,
    completion_callback = tab_complete,
    keypressed_callback = function(_, key, command)
      if key == "Escape" then
        bm:close()
      end

      if key ~= "Tab" and key ~= "Shift_R" then
        changed_callback(command)
      end
    end
  }
end

bm:connect_signal("setstate::open", promptme)

return {
  prompt,
  prompt_color,
  forced_height = dpi(30),
  layout  = wibox.layout.fixed.horizontal,
}
