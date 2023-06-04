
-- █▀▀ █▀█ ▄▀█ █░░ █▀
-- █▄█ █▄█ █▀█ █▄▄ ▄█

-- I keep track of my goals using Taskwarrior.
-- Goals have their own tag and are subdivided into subcategories using projects.

local awful   = require("awful")
local gobject = require("gears.object")
local gtable  = require("gears.table")
local gfs   = require("gears.filesystem")
local json  = require("modules.json")
local color = require("utils.color")
local beautiful = require("beautiful")

local goals = {}
local instance = nil

local JSON_EXPORT = ' export rc.json.array=on'

------------------------

local function gen_accents(base)
  return { color.lighten(base, 0.32), color.darken(base, 0.32 )}
end

function goals:fetch_longterm()
  local cmd = "task tag:Goals timespan:long" .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.longterm = json.decode(stdout)
    self:emit_signal("ready::longterm")
  end)
end

function goals:fetch_shortterm()
  local cmd = "task tag:Goals timespan:short" .. JSON_EXPORT
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self.shortterm = json.decode(stdout)
    self:emit_signal("ready::shortterm")
  end)
end

function goals:gen_twdeps_image(taskid, project)
  local task_cmd = "task tag:Goals project:'"..project.."' export "
  local twdeps_args = " --taskid="..taskid..
                      " --fg="..beautiful.fg..
                      " --sbfg="..beautiful.neutral[300]..
                      " --bg="..beautiful.neutral[900]..
                      " --nodebg="..beautiful.neutral[800]..
                      " --selbg="..beautiful.primary[100]..
                      " --selfg="..beautiful.primary[700]..
                      " --selsbfg="..beautiful.primary[500]..
                      " --green="..beautiful.green[400]..
                      " --fontname='"..beautiful.font_name.."'"
  local twdeps_cmd = "twdeps " .. twdeps_args .. '> ' .. self.deps_img_path
  local cmd = task_cmd .. ' | ' .. twdeps_cmd
  awful.spawn.easy_async_with_shell(cmd, function()
    self:emit_signal("ready::image")
  end)
end

-------------------------

function goals:new()
  self.deps_img_path = gfs.get_cache_dir() .. "goals.svg"

  local accents = beautiful.accents
  self.focus = {
    career    = gen_accents(accents[1]),
    financial = gen_accents(accents[2]),
    personal  = gen_accents(accents[3]),
    physical  = gen_accents(accents[4]),
    social    = gen_accents(accents[5]),
    intellectual = {gen_accents(accents[6])},
  }

  self.focus_default = {
    beautiful.primary[100],
    beautiful.primary[700]
  }

  self:fetch_shortterm()
  self:fetch_longterm()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, goals, true)
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
