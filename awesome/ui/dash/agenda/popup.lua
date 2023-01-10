
-- █▀▀ ▄▀█ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀█    █▀█ █▀█ █▀█ █░█ █▀█ 
-- █▄▄ █▀█ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▀▄    █▀▀ █▄█ █▀▀ █▄█ █▀▀ 

-- Popup used to add event

local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local beautiful = require("beautiful")
local dpi = xresources.apply_dpi
local area = require("modules.keynav.area")
local navbase = require("modules.keynav.navitem").Base
local navbg = require("modules.keynav.navitem").Background
local gears = require("gears")
local cal = require("core.system.cal")

local box = require("helpers.ui").create_boxed_widget
local colorize = require("helpers.ui").colorize_text
local color = require("helpers.color")


