
-- █▀▀ █▀█ █▀█ █▀▀ ▀    ▀█▀ ▄▀█ █▀ █▄▀ █░█░█ ▄▀█ █▀█ █▀█ █ █▀█ █▀█
-- █▄▄ █▄█ █▀▄ ██▄ ▄    ░█░ █▀█ ▄█ █░█ ▀▄▀▄▀ █▀█ █▀▄ █▀▄ █ █▄█ █▀▄

local taskcore = { }

function taskcore:get_tasks_for_tag(tag)

end

function taskcore:set_current_tag(tag)
  self._private.tag = tag
end

function taskcore:get_current_tag()
  return self._private.tag
end
