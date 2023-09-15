
-- █▀▀ █▀█ █▀▀ ▄▀█ ▀█▀ █ █▀█ █▄░█
-- █▄▄ █▀▄ ██▄ █▀█ ░█░ █ █▄█ █░▀█
-- 
-- █▀▀ █░█ █▄░█ █▀▀ ▀█▀ █ █▀█ █▄░█ █▀
-- █▀░ █▄█ █░▀█ █▄▄ ░█░ █ █▄█ █░▀█ ▄█

local ui        = require("utils.ui")
local dpi       = ui.dpi
local btn       = require("frontend.widget.button")
local sbtn      = require("frontend.widget.stateful-button")
local beautiful = require("beautiful")

return function(actions)
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
  local function create_stateful_qa(args)
    local qa = sbtn({
      text     = args.icon,
      height   = dpi(40),
      width    = dpi(40),
      on_press = function(self)
        self.selected = not self.selected
        self:update()

        if self.selected then
          args.activate()
        else
          args.deactivate()
        end
      end,
    })

    function qa:setstate(is_active)
      self.selected = is_active
      self:update()
    end

    args.init(qa)

    qa.name = args.name
    actions[#actions + 1] = qa
  end

  --- @function create_stateless_qa
  -- @brief Creates a simple, stateless quick action.
  -- @param name  Name of the quick action.
  -- @param icon  Nerd Font icon.
  -- @param func  Function to run whenever it's pressed.
  local function create_stateless_qa(args)
    local qa = btn({
      text   = args.icon,
      height = dpi(40),
      width  = dpi(40),
      func   = args.on_press,
      bg     = beautiful.neutral[700],
      bg_mo  = beautiful.neutral[600],
    })
    qa.name = args.name
    actions[#actions + 1] = qa
  end

  return {
    create_stateless_qa,
    create_stateful_qa
  }
end
