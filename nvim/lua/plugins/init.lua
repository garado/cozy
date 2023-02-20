
-- █▀█ █░░ █░█ █▀▀ █ █▄░█ █▀ 
-- █▀▀ █▄▄ █▄█ █▄█ █ █░▀█ ▄█ 

-- Initialize Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- List of plugins is spread throughout a bunch of files
-- Crush them together then pass them to lazy

local function crush(t1, t2)
  for i = 1, #t2 do
    t1[#t1+1] = t2[i]
  end
  return t1
end

local plugin_files = {
  require("plugins.core"),
  require("plugins.ui"),
  require("plugins.qol"),
  require("plugins.misc"),
}

local plugins = {}

for i = 1, #plugin_files do
  crush(plugins, plugin_files[i])
end

require("lazy").setup{plugins}
