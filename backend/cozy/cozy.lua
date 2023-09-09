
-- █▀▀ █▀█ ▀█ █▄█ 
-- █▄▄ █▄█ █▄ ░█░ 

-- Can control state of all of Cozy's popups. Used primarily for closing all popups at once.
-- To avoid circular dependencies, we have to require() inside of functions.

local cozy = {}

local POPUPS = {
  "themeswitch",
  "control",
  "dash",
  "bluetooth",
  "notrofi",
  "kitty",
}

function cozy:close_all()
  for i = 1, #POPUPS do
    local path = "backend.cozy." .. POPUPS[i]
    require(path):close()
  end
end

function cozy:close_all_except(exception)
  for i = 1, #POPUPS do
    if POPUPS[i] ~= exception then
      local path = "backend.cozy." .. POPUPS[i]
      require(path):close()
    end
  end
end

return cozy
