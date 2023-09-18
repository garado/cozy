
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

-- Can control state of all of Cozy's popups. Used primarily for closing all popups at once.
-- To avoid circular dependencies, we have to require() inside of functions.

local cozy = require("gears.object"){}
cozy.popups = {}

function cozy:add_popup(name)
  self.popups[#self.popups+1] = name
end

function cozy:close_all()
  for i = 1, #self.popups do
    require("backend.cozy")[self.popups[i]]:close()
  end
end

function cozy:close_all_except(exception)
  for i = 1, #self.popups do
    if self.popups[i] ~= exception then
      local path = "backend.cozy." .. self.popups[i]

      -- compatibility with new backend
      if require("backend.cozy")[self.popups[i]] then
        require("backend.cozy")[self.popups[i]]:close()
      else
        require(path):close()
      end
    end
  end
end

return cozy
