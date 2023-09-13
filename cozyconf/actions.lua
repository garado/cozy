
-- ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- █▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local ui        = require("utils.ui")
local dpi       = ui.dpi
local btn       = require("frontend.widget.button")
local sbtn      = require("frontend.widget.stateful-button")
local awful     = require("awful")
local gears     = require("gears")
local apps      = require("sysconf.apps")
local naughty   = require("naughty")
local beautiful = require("beautiful")
local control   = require("backend.cozy.control")

local HOME = os.getenv("HOME")
local CFG = gears.filesystem.get_configuration_dir()
local SCRIPTS_PATH = CFG .. "utils/scripts/"

local actions = {}

--- @method create_stateful_qa
-- @brief Used to create a quick action that can be either active or inactive. Pressing
--        the quick action changes its state.
-- @param name   The name of the quick action.
-- @param icon   Nerd Font icon.
-- @param init        Function to determine the initial state of the quick action.
--                    Takes the quick action itself as a parameter and does
--                    quickaction:emit_signal("setstate", <state>)
--                    i.e. if you had an action to toggle Redshift, init_func would
--                    do quickaction:emit_signal("setstate", true) if an active Redshift
--                    process was found and quickaction:emit_signal("setstate", false) otherwise.
-- @param activate    Function that runs whenever a deactivated action is pressed.
--                    This would for example start the Redshift process.
-- @param deactivate  Function that runs whenever an activated action is pressed.
--                    This would for example kill Redshift.
local function create_stateful_qa(name, icon, init, activate, deactivate)
  local qa = sbtn({
    text     = icon,
    height   = dpi(40),
    width    = dpi(40),
    on_press = function(self)
      self.selected = not self.selected
      self:update()

      if self.selected then
        activate()
      else
        deactivate()
      end
    end,
  })

  init(qa)

  qa:connect_signal("setstate", function(self, newstate)
    self.selected = newstate
    self:update()
  end)

  qa.name = name
  actions[#actions + 1] = qa
end

--- @function create_stateless_qa
-- @brief Creates a simple, stateless quick action.
-- @param name  Name of the quick action.
-- @param icon  Nerd Font icon.
-- @param func  Function to run whenever it's pressed.
local function create_stateless_qa(name, icon, on_press)
  local qa = btn({
    text   = icon,
    height = dpi(40),
    width  = dpi(40),
    func   = on_press,
    bg     = beautiful.neutral[700],
    bg_mo  = beautiful.neutral[600],
  })
  qa.name = name
  actions[#actions + 1] = qa
end

-------------- START MAKING CHANGES BELOW HERE -------------------

-- █▀█ █▀▀ █▀▄ █▀ █░█ █ █▀▀ ▀█▀ 
-- █▀▄ ██▄ █▄▀ ▄█ █▀█ █ █▀░ ░█░ 

-- Make sure you have ~/.config/redshift.conf set up for this.

create_stateful_qa("Redshift", "",
  -- Init
  function(qa)
    local cmd = "ps -e | grep redshift"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      qa:emit_signal("setstate", stdout ~= "")
    end)
  end,

  -- Activate
  function()
    local cmd = "redshift"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  -- Deactivate
  function()
    local cmd = "pkill redshift"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
)


-- █ █▀▄ █▀▀ ▄▀█ █▀█ ▄▀█ █▀▄    █▀▀ █▀▄▀█
-- █ █▄▀ ██▄ █▀█ █▀▀ █▀█ █▄▀    █▄▄ █░▀░█

-- Toggles battery conservation mode for ideapad laptops.
-- Requires ideapad-cm (AUR)

-- Script requires root privileges; add to /etc/sudoers
local CM_PATH = SCRIPTS_PATH .. "/ideapad-cm-toggle"

create_stateful_qa("Conservation Mode", "󱊢",
  -- Init
  function(qa)
    local cmd = "ideapad-cm status"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      qa:emit_signal("setstate", stdout:find("enabled"))
    end)
  end,

  -- Activate
  function()
    local cmd = "sudo "..CM_PATH
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  -- Deactivate
  function()
    local cmd = "sudo "..CM_PATH
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
)


-- ░░█ ▄▀█ █▀▄▀█    █▀ █▀▀ █▀ █░█
-- █▄█ █▀█ █░▀░█    ▄█ ██▄ ▄█ █▀█

-- Sets up a bunch of music stuff

create_stateless_qa("Jam Sesh Setup", "󰋄", function()
  local cmd = "jack_control start"
  awful.spawn.easy_async_with_shell(cmd, function()
    control:close()

    awful.tag.viewonly(screen[1].tags[8])

    awful.spawn("firefox https://g.co/kgs/JUJ6pd", { tag = "6" }) -- Google's metronome
    awful.spawn("zathura", { tag = "7" })
    awful.spawn("guitarix", { tag = "8" })
  end)
end)


-- █░█ █▀▄ █▀▄▀█ █
-- █▀█ █▄▀ █░▀░█ █

create_stateless_qa("HDMI", "󰡁", function()
  local cmd = "xrandr --output HDMI-A-0 --mode 1920x1080"
  awful.spawn.easy_async_with_shell(cmd, function() end)
end)


-- █▀▀ ▄▀█ █░░ █▀▀ █░█ █░░ ▄▀█ ▀█▀ █▀█ █▀█
-- █▄▄ █▀█ █▄▄ █▄▄ █▄█ █▄▄ █▀█ ░█░ █▄█ █▀▄

create_stateless_qa("Calculator", "󰪚", function()
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
end)


-- █▀█ █▀█ ▀█▀ ▄▀█ ▀█▀ █▀▀ 
-- █▀▄ █▄█ ░█░ █▀█ ░█░ ██▄ 

create_stateless_qa("Rotate", "", function()
end)


-- █░░ █▀▄▀█ ▄▀█ █▀█
-- █▄▄ █░▀░█ █▀█ █▄█

-- TODO: why tf doesn't setting the height work
local LMAO_PATH = HOME.."/Videos/lmao/"
create_stateless_qa("lmao", "", function()
  control:close()
  local rand = gears.filesystem.get_random_file_from_dir(LMAO_PATH)
  awful.spawn("mpv "..LMAO_PATH..rand, {
    ontop = true,
    placement = awful.placement.centered,
  })
end)


-- █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█    █▀█ █▀▀ █▀▀ █▀█ █▀█ █▀▄ 
-- ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█    █▀▄ ██▄ █▄▄ █▄█ █▀▄ █▄▀ 

create_stateful_qa("Dash: Screen record", "",
  -- Init
  function(qa)
    qa:emit_signal("setstate", false)
  end,

  -- Activate
  function()
    local cmd = 'ffmpeg -y -video_size 1370x830 -framerate 40 -f x11grab -i :0.0+275,125 $HOME/Videos/cozy/output.mp4'
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  -- Deactivate
  function()
    local cmd = "pkill ffmpeg"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
)

create_stateless_qa("Dash: Screenshot", "󰹑", function()
  local cmd = "sleep 4 ; scrot -a 275,125,1370,830 -F $HOME/Videos/cozy/dashpic.png"
  awful.spawn.easy_async_with_shell(cmd, function()
    naughty.notification {
      app_name = "Cozy",
      title = "Quick actions",
      message = "Screenshot taken",
    }
  end)
end)

create_stateful_qa("Airplane mode", "󱐟",
  -- Init
  function(qa)
    local cmd = "rfkill list all"
    awful.spawn.easy_async_with_shell(cmd, function(stdout)
      qa:emit_signal("setstate", stdout:find("yes"))
    end)
  end,

  -- Activate
  function()
    local cmd = "rfkill block all"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end,

  -- Deactivate
  function()
    local cmd = "rfkill unblock all"
    awful.spawn.easy_async_with_shell(cmd, function() end)
  end
)

return actions
