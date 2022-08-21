
-- █▀▀ █░░ █ █▀▀ █▄░█ ▀█▀   █░█ █▀▀ █░░ █▀█ █▀▀ █▀█ █▀
-- █▄▄ █▄▄ █ ██▄ █░▀█ ░█░   █▀█ ██▄ █▄▄ █▀▀ ██▄ █▀▄ ▄█

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local capi = { client = client, mouse = mouse }

local _client = { }

function _client.centered_client_placement(c)
	return gears.timer.delayed_call(function()
		awful.placement.centered(c, { honor_padding = true, honor_workarea = true })
	end)
end

return _client
