
-- █▀█ █░█ █ █▀▀ █▄▀    ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- ▀▀█ █▄█ █ █▄▄ █░█    █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

-- This file defines the quick actions that show in the control center.

local apps  = require("sysconf.apps")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local control = require("backend.cozy").control

local HOME = os.getenv("HOME")
local CFG = gears.filesystem.get_configuration_dir()
local SCRIPTS_PATH = CFG .. "utils/scripts/"

local actions = {}
local ret = require("frontend.control._qa_functions")(actions)
local create_stateless_qa = ret[1]
local create_stateful_qa  = ret[2]

-------------- START MAKING CHANGES BELOW HERE -------------------

-- To add your quick actions, use the provided create_stateful_qa and create_stateless_qa functions.
-- Stateless actions run the same function every time they're pressed.
-- Stateful actions have an 'on' and 'off' state and run different functions when pressed depending on their state.
-- See below for examples from my personal config.

-- You can add as many actions as you want. The QA grid has strictly 5 columns.

-- The order in which you put the creation functions is the order they'll appear in the control center.

-- █▀█ █▀▀ █▀▄ █▀ █░█ █ █▀▀ ▀█▀    ▀█▀ █▀█ █▀▀ █▀▀ █░░ █▀▀ 
-- █▀▄ ██▄ █▄▀ ▄█ █▀█ █ █▀░ ░█░    ░█░ █▄█ █▄█ █▄█ █▄▄ ██▄ 

-- Make sure you have ~/.config/redshift.conf set up for this.

create_stateful_qa({
  name = "Redshift",
  icon = "",

  -- Sets the initial state for the QA.
  init = function(qa)
    -- Search for an active Redshift instance.
    local cmd = "ps -e | grep redshift"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      -- True if QA should be active, false otherwise.
      qa:setstate(stdout ~= "")
    end)
  end,

  -- This function runs when you turn on the QA.
  activate = function()
    local cmd = "redshift"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  -- This function runs when you turn off the QA.
  deactivate = function()
    local cmd = "pkill redshift"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,
})

-- █ █▀▄ █▀▀ ▄▀█ █▀█ ▄▀█ █▀▄    █▀▀ █▀▄▀█
-- █ █▄▀ ██▄ █▀█ █▀▀ █▀█ █▄▀    █▄▄ █░▀░█

-- Toggles battery conservation mode for Lenovo Ideapad laptops.
-- Requires ideapad-cm (AUR)

-- Script requires root privileges; add to /etc/sudoers
local CM_PATH = SCRIPTS_PATH .. "/ideapad-cm-toggle"

create_stateful_qa({
  name = "Conservation Mode",
  icon = "󱊢",

  init = function(qa)
    local cmd = "ideapad-cm status"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      qa:setstate(stdout:find("enabled"))
    end)
  end,

  activate = function()
    local cmd = "sudo "..CM_PATH
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  deactivate = function()
    local cmd = "sudo "..CM_PATH
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
})


-- ░░█ ▄▀█ █▀▄▀█    █▀ █▀▀ █▀ █░█
-- █▄█ █▀█ █░▀░█    ▄█ ██▄ ▄█ █▀█

-- Sets up a bunch of music stuff

create_stateless_qa({
  name = "Jam Sesh Setup",
  icon = "󰋄",
  on_press = function()
    local cmd = "jack_control start"
    awful.spawn.easy_async_with_shell(cmd, function()
      control:close() -- Close control center

      awful.tag.viewonly(screen[1].tags[8]) -- Switch to 8th tag

      awful.spawn("firefox https://g.co/kgs/JUJ6pd", { tag = "6" }) -- Google metronome
      awful.spawn("zathura", { tag = "7" })
      awful.spawn("guitarix", { tag = "8" })
    end)
  end
})


-- █░█ █▀▄ █▀▄▀█ █
-- █▀█ █▄▀ █░▀░█ █

-- Enable HDMI output.

create_stateless_qa({
  name = "HDMI",
  icon = "󰡁",
  on_press = function()
    local cmd = "xrandr --output HDMI-A-0 --mode 1920x1080"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
})


-- █▀▀ ▄▀█ █░░ █▀▀ █░█ █░░ ▄▀█ ▀█▀ █▀█ █▀█
-- █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▄▄ █▀█ ░█░ █▄█ █▀▄

-- Open floating window with Python (i use that as my calculator)

create_stateless_qa({
  name = "Calculator",
  icon = "󰪚",
  on_press = function()
  awful.spawn(apps.default.terminal .. " -e python", {
      width  = 600,
      height = 400,
      floating  = true,
      ontop     = true,
      sticky    = true,
      tag       = mouse.screen.selected_tag,
      placement = awful.placement.bottom_right,
    })
    control:close()
  end
})


-- █▀█ █▀█ ▀█▀ ▄▀█ ▀█▀ █▀▀ 
-- █▀▄ █▄█ ░█░ █▀█ ░█░ ██▄ 

-- Unimplemented

create_stateless_qa({
  name = "Rotate",
  icon = "",
  on_press = function() end
})


-- █░░ █▀▄▀█ ▄▀█ █▀█
-- █▄▄ █░▀░█ █▀█ █▄█

-- Open a random meme.

local LMAO_PATH = HOME.."/Videos/lmao/"
create_stateless_qa({
  name = "lmao",
  icon = "",
  on_press = function()
    control:close()
    local rand = gears.filesystem.get_random_file_from_dir(LMAO_PATH)
    awful.spawn("mpv "..LMAO_PATH..rand, {
      -- TODO: why tf doesn't setting the height work
      ontop = true,
      placement = awful.placement.centered,
    })
  end
})


-- █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█    █▀█ █▀▀ █▀▀ █▀█ █▀█ █▀▄ 
-- ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█    █▀▄ ██▄ █▄▄ █▄█ █▀▄ █▄▀ 

-- Screen record the dashboard

create_stateful_qa({
  name = "Dash: Screen record",
  icon = "",

  init = function(qa)
    qa:setstate(false)
  end,

  activate = function()
    local cmd = 'ffmpeg -y -video_size 1370x830 -framerate 40 -f x11grab -i :0.0+275,125 $HOME/Videos/cozy/output.mp4'
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  deactivate = function()
    local cmd = "pkill ffmpeg"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
})


-- █▀▄ ▄▀█ █▀ █░█    █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█ █▀ █░█ █▀█ ▀█▀ 
-- █▄▀ █▀█ ▄█ █▀█    ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█ ▄█ █▀█ █▄█ ░█░ 

create_stateless_qa({
  name = "Dash: Screenshot",
  icon = "󰹑",
  on_press = function()
    local cmd = "sleep 4 ; scrot -a 275,125,1370,830 -F $HOME/Videos/cozy/dashpic.png"
    awful.spawn.easy_async_with_shell(cmd, function()
      naughty.notification {
        app_name = "Cozy",
        title = "Quick actions",
        message = "Screenshot taken",
      }
    end)
  end
})


-- ▄▀█ █ █▀█ █▀█ █░░ ▄▀█ █▄░█ █▀▀    █▀▄▀█ █▀█ █▀▄ █▀▀ 
-- █▀█ █ █▀▄ █▀▀ █▄▄ █▀█ █░▀█ ██▄    █░▀░█ █▄█ █▄▀ ██▄ 

create_stateful_qa({
  name = "Airplane mode",
  icon = "󰀝",

  init = function(qa)
    local cmd = "rfkill list all"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      qa:setstate(stdout:find("yes"))
    end)
  end,

  activate = function()
    local cmd = "rfkill block all"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  deactivate = function()
    local cmd = "rfkill unblock all"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
})

return actions
